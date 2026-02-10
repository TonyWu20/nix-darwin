{ pkgs, lib, ... }:
let
  catppuccin_programs = [ "fzf" "bat" "fish" "skim" "nushell" ];
in
{
  home.stateVersion = "25.05";
  imports = [
    ./fish
    ./starship
    ./wezterm
    ./nvim
    ./tmux
    ./skhd
    # ./nushell
  ];

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
  programs.yazi = {
    enable = true;
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


  home.packages = with pkgs; [
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
    bat
    gh
    sad
    fzf
    skim
    nushell
    tmux
    eza
    btop
    nodejs-slim_24
    source-sans-pro
    imagemagick
    rar
    simple-http-server

    # Dev stuff
    # (agda.withPackages (p: [ p.standard-library ]))

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    # comma # run software from without installing it
    niv # easy dependency management for nix projects
    nom

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
    skhd
    yabai
  ];
  catppuccin = lib.attrsets.genAttrs catppuccin_programs (prog: { enable = true; flavor = "macchiato"; });
  programs.git = {
    enable = true;
    settings.user = {
      name = "TonyWu20";
      email = "tony.w21@gmail.com";
    };
  };
  programs.delta.enable = true;
  programs.fzf = {
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
}
