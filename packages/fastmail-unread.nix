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

      SESSION=$(curl -sfL -H "Authorization: Bearer $TOKEN" \
        https://api.fastmail.com/.well-known/jmap)

      API_URL=$(printf '%s' "$SESSION" | jq -r '.apiUrl')
      ACCOUNT_ID=$(printf '%s' "$SESSION" \
        | jq -r '.primaryAccounts["urn:ietf:params:jmap:mail"]')

      UNREAD=$(curl -sfL \
        -H "Authorization: Bearer $TOKEN" \
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
