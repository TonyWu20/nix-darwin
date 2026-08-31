{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types optionalAttrs;
  cfg = config.services.duckdns;

  # The token is a sops-decrypted secret, available in the home-manager context.
  # It is installed into the user session by the sops-nix agent at login.
  tokenPath = config.sops.secrets.duckdns_token.path;

  updater = pkgs.writeScript "duckdns-update" ''
    #!/bin/sh
    # The sops secret is materialized by the sops-nix agent at login.
    # If it is not ready yet (startup race), skip and let the interval retry.
    if [ ! -r "${tokenPath}" ]; then
      printf '%s duckdns %s -> token not ready, will retry\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "${cfg.domain}"
      exit 0
    fi
    TOKEN="$(cat "${tokenPath}")"
    resp=$(${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=${cfg.domain}&token=$TOKEN&verbose=true" 2>/dev/null)
    printf '%s duckdns %s -> %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "${cfg.domain}" "$resp"
  '';

  logPaths = optionalAttrs (cfg.logPath != null) {
    StandardOutPath = cfg.logPath;
    StandardErrorPath = cfg.logPath;
  };
in
{
  options.services.duckdns = {
    enable = mkEnableOption "a DuckDNS updater that keeps <domain>.duckdns.org pointing at this host";

    domain = mkOption {
      type = types.str;
      description = "The DuckDNS subdomain, without the .duckdns.org suffix. For example: tony-yiyi.";
      example = "tony-yiyi";
    };

    interval = mkOption {
      type = types.int;
      default = 300;
      description = "Seconds between update checks.";
    };

    logPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/Users/tony/Library/Logs/duckdns.log";
      description = "File for stdout and stderr. Null means the unified log.";
    };
  };

  config = mkIf cfg.enable {
    launchd.agents.duckdns = {
      enable = true;
      config =
        {
          Program = "${updater}";
          RunAtLoad = true;
          StartInterval = cfg.interval;
        }
        // logPaths;
    };
  };
}
