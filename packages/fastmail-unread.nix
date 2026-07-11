{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      curl
      jq
    ];

    text = ''
      TOKEN=$(cat "$1")

      CURL_CONFIG=$(mktemp)
      chmod 600 "$CURL_CONFIG"
      printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" > "$CURL_CONFIG"
      trap 'rm -f "$CURL_CONFIG"' EXIT

      CACHE="$XDG_RUNTIME_DIR/fastmail-unread.cache"

      if [ ! -f "$CACHE" ]; then
        SESSION=$(curl -sfL --config "$CURL_CONFIG" \
          https://api.fastmail.com/.well-known/jmap)
        printf '%s\n%s\n' \
          "$(printf '%s' "$SESSION" | jq -r '.apiUrl')" \
          "$(printf '%s' "$SESSION" | jq -r '.primaryAccounts["urn:ietf:params:jmap:mail"]')" \
          > "$CACHE"
      fi

      API_URL=$(sed -n '1p' "$CACHE")
      ACCOUNT_ID=$(sed -n '2p' "$CACHE")

      UNREAD=$(curl -sfL \
        --config "$CURL_CONFIG" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg id "$ACCOUNT_ID" '{
              using: ["urn:ietf:params:jmap:core","urn:ietf:params:jmap:mail"],
              methodCalls: [
                ["Mailbox/query",{"accountId":$id,"filter":{"role":"inbox"}},"q"],
                ["Mailbox/get",{"accountId":$id,"#ids":{"resultOf":"q","name":"Mailbox/query","path":"/ids"}},"g"]
              ]
            }')" "$API_URL" \
        | jq '.methodResponses[1][1].list[0].unreadEmails // 0')

      if [ "$UNREAD" -gt 0 ]; then
        printf '{"text":"%s","tooltip":"%s unread in inbox","class":"unread"}\n' \
          "$UNREAD" "$UNREAD"
      else
        printf '{"text":"","tooltip":"Inbox clear"}\n'
      fi
    '';

    meta.platforms = lib.platforms.linux;
  }
