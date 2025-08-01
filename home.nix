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
    ./nushell
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

    # Dev stuff
    # (agda.withPackages (p: [ p.standard-library ]))

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    # comma # run software from without installing it
    niv # easy dependency management for nix projects

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
    skhd
    yabai
  ];
  catppuccin = lib.attrsets.genAttrs catppuccin_programs (prog: { enable = true; flavor = "macchiato"; });
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      github = {
        host = "github.com";
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      nix = {
        host = "nix";
        user = "tony";
        hostname = "10.147.17.20";
        identityFile = "~/.ssh/id_ed25519";
      };
      mac-mini = {
        host = "mac";
        user = "tonywu";
        hostname = "10.147.17.25";
        identityFile = "~/.ssh/id_ed25519";
      };
      klt = {
        host = "klt";
        user = "klt";
        hostname = "10.147.17.146";
        identityFile = "~/.ssh/id_ed25519";
        forwardX11 = true;
      };
      local-mini = {
        host = "local-mini";
        user = "tonywu";
        hostname = "10.0.0.5";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
  programs.git = {
    enable = true;
    userName = "TonyWu20";
    userEmail = "tony.w21@gmail.com";
    delta = {
      enable = true;
    };
  };
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
