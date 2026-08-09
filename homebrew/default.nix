{ ... }: {
  imports = [ ./fix-brew-bundle.nix ];

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
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
      "obs"
    ];
  };
}
