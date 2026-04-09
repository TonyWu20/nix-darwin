{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    # ghostty-bin is essential for macOS stability in Nixpkgs
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    settings = {
      font-size = 12;

      # Native Claude Code notifications via OSC 9
      desktop-notifications = true;

      # Ensures you see Claude's 'Needs Input' alerts globally
      notification-handling-method = "AlwaysShow";

      # Performance and UX
      window-decoration = false;
      confirm-close-surface = false;

      # Claude-specific keybinds
      keybind = [
        "super+d=new_split:right"
        "super+shift+d=new_split:down"
      ];
    };
  };
}

