{ config, lib, pkgs, ... }:
let
  cfg = config.homebrew;
  brewfileFile = pkgs.writeText "Brewfile" cfg.brewfile;

  # Build the brew bundle command with correct --cleanup (not --force-cleanup)
  brewBundleInstall = lib.concatStringsSep " " (
    [
      ''PATH="${cfg.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH"''
      "sudo"
      "--preserve-env=PATH"
      "--user=${lib.escapeShellArg cfg.user}"
      "--set-home"
      "env"
    ]
    ++ lib.optional (!cfg.onActivation.autoUpdate) "HOMEBREW_NO_AUTO_UPDATE=1"
    ++ lib.mapAttrsToList (k: v: "${k}=${lib.escapeShellArg v}") cfg.onActivation.extraEnv
    ++ [ "brew bundle --file='${brewfileFile}'" ]
    ++ lib.optional (!cfg.onActivation.upgrade) "--no-upgrade"
    ++ lib.optional (cfg.onActivation.cleanup == "uninstall") "--cleanup"
    ++ lib.optional (cfg.onActivation.cleanup == "zap") "--zap --cleanup"
    ++ cfg.onActivation.extraFlags
  );

  brewBundleCheck = lib.concatStringsSep " " (
    [
      ''PATH="${cfg.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH"''
      "sudo"
      "--preserve-env=PATH"
      "--user=${lib.escapeShellArg cfg.user}"
      "--set-home"
      "env"
      "HOMEBREW_NO_AUTO_UPDATE=1"
    ]
    ++ lib.mapAttrsToList (k: v: "${k}=${lib.escapeShellArg v}") cfg.onActivation.extraEnv
    ++ [ "brew bundle --file='${brewfileFile}'" "cleanup" "2>&1" ]
  );
in
{
  system.activationScripts.homebrew.text = lib.mkForce (
    if cfg.enable then ''
      # Homebrew Bundle
      echo >&2 "Homebrew bundle..."
      if [ -f "${cfg.prefix}/bin/brew" ]; then
        ${brewBundleInstall}
      else
        echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
      fi
    '' else ""
  );

  system.checks.text = lib.mkIf (cfg.enable && cfg.onActivation.cleanup == "check") ''
    if [ -f "${cfg.prefix}/bin/brew" ]; then
      homebrewCleanupExitCode=0
      homebrewCleanupResult=$(${brewBundleCheck}) || homebrewCleanupExitCode=$?
      if [ "$homebrewCleanupExitCode" -eq 1 ]; then
        printf >&2 '\e[1;31merror: found Homebrew packages not listed in the Brewfile, aborting activation\e[0m\n'
        printf >&2 '%s\n' "$homebrewCleanupResult"
        printf >&2 '\n'
        printf >&2 'To fix this, either:\n'
        printf >&2 '  - Add the listed packages to your nix-darwin Homebrew configuration\n'
        printf >&2 '  - Remove them by running: brew bundle cleanup --force\n'
        printf >&2 '  - Set homebrew.onActivation.cleanup to "uninstall" or "zap"\n'
        exit 2
      elif [ "$homebrewCleanupExitCode" -ne 0 ]; then
        printf >&2 '\e[1;31merror: brew bundle cleanup failed, aborting activation\e[0m\n'
        printf >&2 '%s\n' "$homebrewCleanupResult"
        exit 2
      fi
    fi
  '';
}
