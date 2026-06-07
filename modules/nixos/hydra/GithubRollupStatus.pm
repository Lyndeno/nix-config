package Hydra::Plugin::GithubRollupStatus;

# Posts ONE GitHub commit status per (eval, commit) instead of one per build.
#
# Design notes:
#   * Level-triggered: both evalAdded and buildFinished run the same
#     `reconcile` routine, which recomputes the eval's aggregate state from
#     scratch and posts whatever it finds.
#   * Eval-time correctness: evalAdded catches the all-cache-hits case in
#     which no buildFinished will ever fire. Eval-level errors (whether the
#     whole eval failed or per-job eval failures concatenated together by
#     hydra-eval-jobset) are detected via evaluationerror->errormsg.
#   * Per-build statuses (Hydra::Plugin::GithubStatus) can remain enabled
#     alongside this plugin; they serve human triage, this serves the gate.
#
# Schema reference (verified against hydra master):
#   * JobsetEvals has nrbuilds, nrsucceeded, flake, evaluationerror_id.
#   * evaluationerror is a belongs_to to EvaluationErrors, which has a
#     single errormsg text column.  Every eval gets an EvaluationErrors row
#     at creation, with errormsg = "" for "no errors".
#   * Per-job eval errors are concatenated into the same errormsg (see
#     hydra-eval-jobset around line 818).  There is no separate per-job
#     error column.
#   * $eval->builds is a many_to_many through jobsetevalmembers.  Cache-hit
#     builds (already finished in a prior eval) are members of the new
#     eval too, so $eval->builds includes them.
#
# Config (hydra.conf):
#   <githubrollup>
#     jobsets = .*
#     context = ci/hydra:nix-config
#     inputs = src
#     # Optional: description override, authorization, useShortContext (n/a).
#     # Plus the same github_authorization.<owner> mechanism as GithubStatus.
#   </githubrollup>

use strict;
use warnings;
use parent 'Hydra::Plugin';
use HTTP::Request;
use JSON::MaybeXS;
use LWP::UserAgent;
use Hydra::Helper::CatalystUtils;
use List::Util qw(max min);

sub isEnabled {
    my ($self) = @_;
    return defined $self->{config}->{githubrollup};
}

sub ua {
    my $u = LWP::UserAgent->new(timeout => 30);
    $u->default_header('User-Agent' => 'hydra-githubrollup/1');
    return $u;
}

# Post a commit status against a single (owner, repo, sha). Retries on 5xx.
# Applies a rate-limit-aware sleep with a 60s ceiling.
sub postStatus {
    my ($self, $authz, $owner, $repo, $rev, $body) = @_;
    my $url = "https://api.github.com/repos/$owner/$repo/statuses/$rev";

    my $ua = ua();
    my $attempts = 0;
    my $res;
    while ($attempts < 3) {
        my $req = HTTP::Request->new('POST', $url);
        $req->header('Content-Type' => 'application/json');
        $req->header('Accept' => 'application/vnd.github.v3+json');
        $req->header('Authorization' => $authz);
        $req->content(encode_json($body));
        $res = $ua->request($req);

        if ($res->is_success) {
            print STDERR "GithubRollupStatus: posted $body->{state} for $owner/$repo\@$rev: $body->{description}\n";
            last;
        }

        my $code = $res->code;
        if ($code >= 500 && $code < 600 && $attempts < 2) {
            $attempts++;
            sleep 2 ** $attempts;
            next;
        }

        print STDERR "GithubRollupStatus: ", $res->status_line, ": ", $res->decoded_content, "\n";
        last;
    }

    # Rate-limit accounting — same shape as GithubStatus.pm but capped at 60s.
    if (defined $res) {
        my $limit          = $res->header("X-RateLimit-Limit");
        my $limitRemaining = $res->header("X-RateLimit-Remaining");
        my $limitReset     = $res->header("X-RateLimit-Reset");
        if (defined $limit && defined $limitRemaining && defined $limitReset) {
            my $diff = $limitReset - time();
            $diff = 1 if $diff < 1;
            my $delay = (($limit - $limitRemaining) / $diff) * 5;
            if ($limitRemaining < 1000) { $delay = max(1, $delay); }
            $delay = min($delay, 60);
            if ($limitRemaining < 2000) {
                print STDERR "GithubRollupStatus: ratelimit $limitRemaining/$limit, resets in $diff, sleeping $delay\n";
                sleep $delay;
            }
        }
    }
}

# Look at a single eval and return:
#   ( state => one of "success"/"failure"/"pending",
#     description => human-readable progress string,
#     source_eval_id => integer — eval whose builds were used (may differ
#                       from the input eval if it was cached) )
sub computeRollup {
    my ($self, $eval) = @_;

    # Eval errors: both whole-eval and per-job are concatenated into the
    # same errormsg by hydra-eval-jobset. Treat any non-empty errormsg as
    # a failure signal that survives even if all builds pass.
    #
    # We bypass $eval->evaluationerror because DBIx caches the related row
    # at the state it had when first fetched. EvaluationErrors is created
    # OUTSIDE the txn with errormsg="" and UPDATEd inside the txn — if the
    # relation was first read pre-update, the cached row remains empty.
    # Direct find() via the FK always issues a fresh SELECT.
    my $errId = $eval->get_column('evaluationerror_id');
    my $errMsg = "";
    if (defined $errId) {
        # Raw DBI to bypass any DBIx::Class caching. Reconnect first to
        # invalidate any prepared statements.
        my $dbh = $self->{db}->storage->dbh;
        my $sth = $dbh->prepare("SELECT errormsg FROM evaluationerrors WHERE id = ?");
        $sth->execute($errId);
        my ($raw) = $sth->fetchrow_array;
        $sth->finish;
        $errMsg = $raw // "";
    }
    my $hasErr = length($errMsg) > 0;

    print STDERR "GithubRollupStatus: eval ", $eval->id,
                 " evaluationerror_id=", ($errId // 'NULL'),
                 " errMsgLen=", length($errMsg),
                 " hasnewbuilds=", $eval->hasnewbuilds,
                 "\n";

    # Cached evals (hasnewbuilds = 0) don't create jobsetevalmembers — see
    # hydra-eval-jobset around line 835. Their `builds` relation is empty.
    # Fall back to the most recent fresh eval (hasnewbuilds = 1) for the
    # same jobset, whose member set reflects the actual build state of the
    # commit being re-evaluated.
    my $sourceEval = $eval;
    if (!$eval->hasnewbuilds && !$hasErr) {
        my $prev = $eval->jobset->jobsetevals->search(
            { id => { '<=' => $eval->id }, hasnewbuilds => 1 },
            { order_by => { -desc => 'id' }, rows => 1 },
        )->first;
        $sourceEval = $prev if defined $prev;
    }

    my $builds = $sourceEval->builds;
    my $totalBuilds = $builds->count;
    my $finishedRs  = $builds->search({ finished => 1 });
    my $finished    = $finishedRs->count;
    my $unfinished  = $totalBuilds - $finished;
    my $succeeded   = $finishedRs->search({ buildstatus => 0 })->count;
    my $failed      = $finished - $succeeded;

    my $sourceId = $sourceEval->id;

    # Whole-eval failure: errors plus zero builds means the evaluator failed
    # before producing any jobs.
    if ($hasErr && $totalBuilds == 0) {
        my $short = substr($errMsg, 0, 130);
        $short =~ s/\s+/ /g;
        return ("failure", "eval failed: $short", $sourceId);
    }

    if ($unfinished > 0) {
        my $done = $succeeded + $failed;
        my $errNote = $hasErr ? ", eval errors present" : "";
        return ("pending", "queued: $done/$totalBuilds builds$errNote", $sourceId);
    }

    # Terminal.
    if ($failed > 0 || $hasErr) {
        my $errNote = $hasErr ? ", eval errors" : "";
        return ("failure", "done: $succeeded ok, $failed failed$errNote", $sourceId);
    }
    return ("success", "done: $succeeded/$totalBuilds builds passed", $sourceId);
}

# Walk eval inputs / flake URI to discover the (owner, repo, sha) targets for
# the status post. Mirrors the parsing in GithubStatus.pm so behavior is
# identical from GitHub's perspective.
sub eachTargetCommit {
    my ($conf, $eval, $cb) = @_;

    my $inputs_cfg = $conf->{inputs};
    my @inputs = defined $inputs_cfg ? ref $inputs_cfg eq "ARRAY" ? @$inputs_cfg : ($inputs_cfg) : ();

    if (defined $eval->flake) {
        my $fl = $eval->flake;
        if ($fl =~ m!github:([^/]+)/([^/]+)/([[:xdigit:]]{40})(\?narHash[^ ]*)?$!
            || $fl =~ m!git\+ssh://git\@github.com/([^/]+)/([^/]+)\?.*rev=([[:xdigit:]]{40})(\?narHash[^ ]*)?$!) {
            $cb->("src", $1, $2, $3);
        } else {
            print STDERR "GithubRollupStatus: can't parse flake URI '$fl', skipping\n";
        }
        return;
    }

    foreach my $input (@inputs) {
        my $i = $eval->jobsetevalinputs->find({ name => $input, altnr => 0 });
        next unless defined $i;
        my $uri = $i->uri;
        my $rev = $i->revision;
        if ($uri =~ m![:/]([^/]+)/([^/]+?)(?:.git)?$!) {
            $cb->($input, $1, $2, $rev);
        }
    }
}

sub reconcile {
    my ($self, $eval) = @_;

    my $cfg = $self->{config}->{githubrollup};
    my @configs = defined $cfg ? ref $cfg eq "ARRAY" ? @$cfg : ($cfg) : ();
    my $baseurl = $self->{config}->{'base_uri'} || "http://localhost:3000";

    my $jobsetName = eval { $eval->jobset->get_column('name') } // "?";

    foreach my $conf (@configs) {
        # The `jobsets` regex on the stanza filters by jobset name.
        if (defined $conf->{jobsets}) {
            next unless $jobsetName =~ /^$conf->{jobsets}$/;
        }

        my ($state, $desc, $sourceId) = computeRollup($self, $eval);
        $desc = $conf->{description} if defined $conf->{description};

        my $context = $conf->{context} // "ci/hydra:rollup";
        my $target_url = $baseurl . "/eval/" . $sourceId;

        my $body = {
            state       => $state,
            target_url  => $target_url,
            description => $desc,
            context     => $context,
        };

        my %seen;
        eachTargetCommit($conf, $eval, sub {
            my ($input, $owner, $repo, $rev) = @_;
            my $key = "$owner/$repo/$rev";
            return if $seen{$key}++;
            my $authz = $self->{config}->{github_authorization}->{$owner} // $conf->{authorization};
            postStatus($self, $authz, $owner, $repo, $rev, $body);
        });
    }
}

# --- Hooks ----------------------------------------------------------------

sub evalAdded {
    my ($self, $trace_id, $jobset, $eval) = @_;
    return unless defined $eval;
    print STDERR "GithubRollupStatus: HOOK evalAdded eval=", $eval->id, "\n";
    reconcile($self, $eval);
}

sub buildFinished {
    my ($self, $build, $dependents) = @_;
    print STDERR "GithubRollupStatus: HOOK buildFinished build=", $build->id, "\n";
    my $evals = $build->jobsetevals;
    while (my $eval = $evals->next) {
        reconcile($self, $eval);
    }
}

sub cachedBuildFinished {
    my ($self, $evaluation, $build) = @_;
    print STDERR "GithubRollupStatus: HOOK cachedBuildFinished eval=", $evaluation->id, " build=", $build->id, "\n";
    reconcile($self, $evaluation);
}

# Optional: keep the PR UI lively as builds tick over. Cheap because reconcile
# is idempotent — GitHub silently no-ops when posting an identical status.
sub buildStarted {
    my ($self, $build) = @_;
    print STDERR "GithubRollupStatus: HOOK buildStarted build=", $build->id, "\n";
    my $evals = $build->jobsetevals;
    while (my $eval = $evals->next) {
        reconcile($self, $eval);
    }
}

1;
