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
    ];
    casks = [ "wezterm" "zerotier-one" "xquartz" ];
  };
}
