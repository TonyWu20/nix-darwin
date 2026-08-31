{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types optionalAttrs;
  cfg = config.services.sing-box;

  # Build-time base document. The VLESS secret fields (uuid, private_key,
  # short_id) are empty placeholders. They are injected at runtime from sops.
  baseConfig = pkgs.writeText "sing-box.json" (builtins.toJSON cfg.settings);

  # sops secrets, materialized into the user session at login by the sops-nix agent.
  uuidPath = config.sops.secrets.vless_uuid.path;
  privPath = config.sops.secrets.vless_private_key.path;
  sidPath = config.sops.secrets.vless_short_id.path;

  # Runtime launcher: read the sops secrets, inject them into the base document,
  # then run sing-box on the result. Keeps the secret values out of the repo.
  launcher = pkgs.writeScript "sing-box-launch" ''
    #!/bin/sh
    set -e
    UUID_FILE="${uuidPath}"
    PRIV_FILE="${privPath}"
    SID_FILE="${sidPath}"
    for f in "$UUID_FILE" "$PRIV_FILE" "$SID_FILE"; do
      if [ ! -r "$f" ]; then
        echo "sing-box: sops secret $f not ready yet; will retry" >&2
        sleep 15
        exit 1
      fi
    done
    UUID="$(cat "$UUID_FILE")"
    PRIV="$(cat "$PRIV_FILE")"
    SID="$(cat "$SID_FILE")"
    OUT="$(mktemp)"
    trap 'rm -f "$OUT"' EXIT
    ${pkgs.jq}/bin/jq -c \
      --arg uuid "$UUID" --arg priv "$PRIV" --arg sid "$SID" \
      '.inbounds[0].users[0].uuid = $uuid
       | .inbounds[0].tls.reality.private_key = $priv
       | .inbounds[0].tls.reality.short_id = [$sid]' \
      "${baseConfig}" > "$OUT"
    exec ${cfg.package}/bin/sing-box run -c "$OUT"
  '';

  logPaths = optionalAttrs (cfg.logPath != null) {
    StandardOutPath = cfg.logPath;
    StandardErrorPath = cfg.logPath;
  };
in
{
  options.services."sing-box" = {
    enable = mkEnableOption "the sing-box VLESS+Reality VPN server, run as a user LaunchAgent";

    package = lib.mkPackageOption pkgs "sing-box" { };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Full sing-box server configuration as a JSON-compatible attrset.
        This is the top-level sing-box JSON document (log, inbounds, outbounds,
        dns, route, ...). See the sing-box documentation:
        https://sing-box.sagernet.org/manual/configuration/
      '';
    };

    logPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/Users/tony/Library/Logs/sing-box.log";
      description = "File for stdout and stderr. Null means the unified log.";
    };
  };

  config = mkIf cfg.enable {
    launchd.agents."sing-box" = {
      enable = true;
      config =
        {
          Program = "${launcher}";
          RunAtLoad = true;
          KeepAlive = true;
        }
        // logPaths;
    };
  };
}
