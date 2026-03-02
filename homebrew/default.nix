{ ... }: {
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = [ "daipeihust/tap" "laishulu/homebrew" ];
    brews = [
      "fish"
      { name = "daipeihust/tap/im-select"; link = true; }
      "laishulu/homebrew/macism"
      "watch"
      "php"
      "librime"
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
    ];
  };
}
