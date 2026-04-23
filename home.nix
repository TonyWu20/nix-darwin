{ pkgs, lib, ... }:
let
  catppuccin_programs = [
    "bat"
    "btop"
    "delta"
    "eza"
    "fish"
    "fzf"
    "ghostty"
    "nushell"
    "skim"
    "starship"
    "yazi"
  ];
in
{
  home = {
    stateVersion = "25.05";

    sessionVariables = {
      LIBRIME_LIB_DIR = "/opt/homebrew/lib";
      LIBRIME_INCLUDE_DIR = "/opt/homebrew/include";
      DYLD_LIBRARY_PATH = "/opt/homebrew/lib";
    };

    packages = with pkgs; [
      # Some basics
      coreutils
      curl
      wget
      wezterm
      fish
      starship
      zoxide
      ripgrep
      fd
      gh
      sad
      skim
      tmux
      eza
      btop
      nodejs_24
      source-sans-pro
      imagemagick
      rar
      simple-http-server
      lua51Packages.luarocks
      lua51Packages.lua
      librime
      python313Packages.pynvim
      python313
      bun
      sd
      # Dev stuff
      # (agda.withPackages (p: [ p.standard-library ]))

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      # comma # run software from without installing it
      niv # easy dependency management for nix projects
      nom
      tun2socks
      mosh
    ] ++ lib.optionals stdenv.isDarwin [
      m-cli # useful macOS CLI commands
    ];
  };

  imports = [
    ./fish
    ./starship
    ./wezterm
    ./nvim
    ./tmux
    ./skhd
    ./rime
    ./sops
    ./nushell
    ./claude-code
    ./ghostty
  ];
  programs = {
    direnv = {

      # https://github.com/malob/nixpkgs/blob/master/home/default.nix

      # Direnv, load and unload environment variables depending on the current directory.
      # https://direnv.net
      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
      enable = true;
      nix-direnv.enable = true;
    };

    # Htop
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
    htop.enable = true;
    htop.settings.show_program_path = true;
    yazi = {
      enable = true;
      shellWrapperName = "y";
      settings = {
        plugins = {
          prepend_previewers = [{
            mime = "image/tiff";
            run = "magick";
          }
            {
              name = "*.tif";
              run = "magick";
            }];
          prepend_preloaders = [
            { mime = "image/tiff"; run = "magick"; }
          ];
        };
      };
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "TonyWu20";
          email = "tony.w21@gmail.com";
        };
        core = {
          quotepath = false;
        };
      };
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        side-by-side = true;
      };
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultOptions = [
        "--height 80%"
        "--reverse"
        "--border"
        "--preview-window right:67%"
      ];
      defaultCommand = "fd --type file -HI -E .git --color=always";
      fileWidgetOptions = [
        "--preview 'bat -n --color=always {}'"
        "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
        "--walker-skip .git,node_modules,target"
      ];
    };
    bat = {
      enable = true;
    };
  };
  catppuccin = lib.attrsets.genAttrs catppuccin_programs (prog: { enable = true; flavor = "macchiato"; });
}
