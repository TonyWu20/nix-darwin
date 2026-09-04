{ pkgs, lib, pi-config, ... }:
let
  # A persistent user ssh-agent, on a stable socket, with the default key
  # auto-loaded. This is what makes `sudo darwin-rebuild` able to fetch the
  # private pi-config input over git+ssh: the agent runs as the user on a
  # known socket, and sudo keeps the SSH_AUTH_SOCK env var (host setup:
  # see the NOTE in configuration.nix).
  agentScript = pkgs.writeScript "ssh-agent-launch" ''
    #!/bin/sh
    SOCK="$HOME/.ssh/agent.sock"
    rm -f "$SOCK"
    exec /usr/bin/ssh-agent -D -a "$SOCK"
  '';

  keyScript = pkgs.writeScript "ssh-agent-key-load" ''
    #!/bin/sh
    SOCK="$HOME/.ssh/agent.sock"
    # `ssh-add -L` exits 1 when the agent holds no key and 0 when it does.
    # Re-add the key whenever it is missing (agent restart clears it).
    while :; do
      if ! SSH_AUTH_SOCK="$SOCK" /usr/bin/ssh-add -L >/dev/null 2>&1; then
        SSH_AUTH_SOCK="$SOCK" /usr/bin/ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
      fi
      sleep 15
    done
  '';
in
{
  launchd.agents."ssh-agent" = {
    enable = true;
    config = {
      Program = "${agentScript}";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.agents."ssh-agent-keys" = {
    enable = true;
    config = {
      Program = "${keyScript}";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  # Export the LaunchAgent socket only when it exists, so shells started
  # before the agent is up do not carry a dead path.
  sshAuthSock = {
    enable = true;
    initialization = {
      nushell = ''
        if ($nu.home-dir | path join ".ssh" "agent.sock" | path exists) {
          $env.SSH_AUTH_SOCK = ($nu.home-dir | path join ".ssh" "agent.sock")
        }
      '';
      fish = ''
        if test -S "$HOME/.ssh/agent.sock"
          set -x SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
        end
      '';
    };
  };
  home = {
    stateVersion = "25.05";

    sessionVariables = {
      LIBRIME_LIB_DIR = "/opt/homebrew/lib";
      LIBRIME_INCLUDE_DIR = "/opt/homebrew/include";
      #DYLD_LIBRARY_PATH = "/opt/homebrew/lib";
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
      bun
      sd
      freetype
      harfbuzz
      fribidi
      libraqm
      zlib
      tree-sitter
      uv
      ty
      wait-for-lsp
      nerd-fonts.hack
      # Dev stuff
      # (agda.withPackages (p: [ p.standard-library ]))

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      # comma # run software from without installing it
      niv # easy dependency management for nix projects
      nix-output-monitor
      tun2socks
      mosh
      tdf
      crossref-cli
      terminal-browser
      sops
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
    ./herdr
  ];
  programs = {
    pi.coding-agent = {
      enable = true;
      package = pi-config.packages.aarch64-darwin.default;
    };
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
      keymap = {
        mgr.prepend_keymap = [
          { run = "plugin handoff -- share_menu"; on = [ "\\" "s" ]; }
        ];
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
      fileWidget.options = [
        "--preview 'bat -n --color=always {}'"
        "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
        "--walker-skip .git,node_modules,target"
      ];
    };
    bat = {
      enable = true;
    };
    btop = {
      enable = true;
    };
    sioyek = {
      enable = true;
    };
  };
  catppuccin = { autoEnable = true; enable = true; flavor = "macchiato"; };
}
