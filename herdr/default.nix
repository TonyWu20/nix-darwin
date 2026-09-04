{ herdr-nix, config, pkgs, lib, ... }:

{
  imports = [ ./herdr-mirror.nix ];

  herdr = {
    enable = true;
    package = herdr-nix.packages.${pkgs.stdenv.system}.herdr;

    config = {
      onboarding = false;

      terminal = {
        default_shell = "fish";
        shell_mode = "auto";
      };

      theme = {
        name = "catppuccin";
        auto_switch = true;
        light_name = "catppuccin-latte";
        dark_name = "catppuccin";
      };

      keys = {
        prefix = "ctrl+b";
        new_tab = "prefix+c";
        next_tab = [ "prefix+n" "ctrl+alt+]" ];
        command = [
          {
            key = "prefix+alt+g";
            type = "popup";
            command = "lazygit";
            description = "run lazygit";
            width = "80%";
            height = "80%";
          }
        ];
      };

      ui = {
        pane_borders = true;
        tab_bar_position = "bottom";
        window_title = "{hostname}: {workspace}";
      };

      experimental = {
        kitty_graphics = false;
      };
    };

    extraConfig = "";
  };
}
