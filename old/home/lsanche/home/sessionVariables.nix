{
  lib,
  osConfig,
}: let
  isDesktop = osConfig.modules.desktop.enable;
in
  lib.mkMerge [
    (lib.mkIf isDesktop {
      BROWSER = "firefox";
      SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$HOME/.1password/agent.sock}";
      GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
    })
  ]
