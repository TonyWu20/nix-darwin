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
    ];
    casks = [ "wezterm" "zerotier-one" "xquartz" ];
  };
}
