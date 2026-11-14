# Personal preferences

## Communication
- Be concise and direct. Lead with the answer or result, skip preamble and recap.
- When weighing options, give a recommendation rather than an exhaustive survey.
- Report outcomes faithfully: if a build or test fails, show the relevant output.

## Git
- Use Conventional Commits: `type(scope): summary` (feat, fix, refactor, docs, chore).
- Keep commits small and concise, each doing one thing. Use a short imperative summary; add a body only when the why is not obvious.
- Do not add Co-Authored-By trailers or "Generated with" lines to commits or PRs.
- Only commit or push when asked. Never commit directly to the default branch; branch first.
- Prefer a separate git worktree when asked to work alongside existing uncommitted changes.

## Nix and NixOS
- Verify with build-only commands (`nix build`, `nixos-rebuild build`, `nix flake check`).
- Never activate a configuration (`switch`, `test`, `boot`) yourself. Say what needs activating and let me run it.
- Format with `alejandra`; keep `statix` and `deadnix` clean.
- Prefer `lib.mkDefault` for overridable values and `lib.mkIf` for conditionals.
- Never put secrets in the Nix store; use agenix.

## Code style
- Match the surrounding code's naming, idiom and comment density.
- Do not comment trivial code. When a comment is needed, keep it to one line; a few lines are fine at the top of a file.
- Do not expand scope beyond what was asked.
