{ pkgs, hostName, ... }:

{
  programs.ghostty = {
    enable = true;
    # ghostty-bin is essential for macOS stability in Nixpkgs
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    settings = {
      alpha-blending = "linear-corrected";
      font-thicken = if hostName == "Tonys-Mac-mini-M4" then true else false;
      font-size = 12;
      font-family = [ "Hack Nerd Font Mono" "Noto Sans Mono CJK SC" ];
      font-family-bold = "Hack Nerd Font Mono Bold";
      font-family-bold-italic = "Hack Nerd Font Mono Bold Italic";
      font-family-italic = "Hack Nerd Font Mono Italic";

      # Native Claude Code notifications via OSC 9
      desktop-notifications = true;

      # Performance and UX
      window-decoration = true;
      confirm-close-surface = false;

      # Claude-specific keybinds
      keybind = [
        "super+d=new_split:right"
        "super+shift+d=new_split:down"
      ];
      macos-option-as-alt = true;
    };
  };
}

