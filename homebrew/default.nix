{ ... }: {
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = [ "daipeihust/tap" "laishulu/homebrew" "lablup/tap" ];
    brews = [
      "fish"
      { name = "daipeihust/tap/im-select"; link = true; }
      "laishulu/homebrew/macism"
      "watch"
      "php"
      "lablup/tap/all-smi"
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
    ];
  };
}
