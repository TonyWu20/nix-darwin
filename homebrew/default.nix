{ config, lib, pkgs, ... }:
let
  brewfileFile = pkgs.writeText "Brewfile" config.homebrew.brewfile;
  cfg = config.homebrew;
in
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      brewBundleCmd = lib.mkForce ({ onlyCheck }: lib.concatStringsSep " " (
        [
          ''PATH="${cfg.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH"''
          "sudo"
          "--preserve-env=PATH"
          "--user=${lib.escapeShellArg cfg.user}"
          "--set-home"
          "env"
        ]
        ++ lib.optional (onlyCheck || !cfg.onActivation.autoUpdate) "HOMEBREW_NO_AUTO_UPDATE=1"
        ++ lib.mapAttrsToList (k: v: "${k}=${lib.escapeShellArg v}") cfg.onActivation.extraEnv
        ++ [ "brew bundle --file='${brewfileFile}'" ]
        ++ (
          if onlyCheck then
            [ "cleanup 2>&1" ]
          else
            lib.optional (!cfg.onActivation.upgrade) "--no-upgrade"
            ++ lib.optional (cfg.onActivation.cleanup == "uninstall") "--cleanup"
            ++ lib.optional (cfg.onActivation.cleanup == "zap") "--zap --cleanup"
            ++ cfg.onActivation.extraFlags
        )
      ));
    };

    taps = [ "daipeihust/tap" "laishulu/homebrew" "lablup/tap" ];
    brews = [
      { name = "daipeihust/tap/im-select"; link = true; }
      "laishulu/homebrew/macism"
      "watch"
      "php"
      "lablup/tap/all-smi"
      "cairo"
      "mole"
    ];
    casks = [
      "wezterm"
      "zerotier-one"
      "xquartz"
      "darktable"
      "zoom"
      "kitty"
      "citra"
      "squirrel-app"
      "ghostty"
      "inkscape"
      "discord"
      "obsidian"
    ];
  };
}
