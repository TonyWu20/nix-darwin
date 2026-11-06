{
  description = "Example nix-darwin system flake ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    my-nvim = {
      url = "github:TonyWu20/my-nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nushell-cfg = {
      #nvimdots = { url = "git+file:///Users/tony/Downloads/nvimdots"; };
      url = "github:TonyWu20/nushell_hm_module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell_plugin_crossref = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:TonyWu20/crossref-rs";
    };
    wait-for-lsp = {
      url = "github:TonyWu20/wait-for-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terminal-browser.url = "github:TonyWu20/terminal-browser-flake";
    rushi-config = {
      url = "github:TonyWu20/my-rushi-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };
    tv-rushi = {
      url = "github:TonyWu20/tv-rushi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tv-himalaya-mail = {
      url = "git+file:///Users/tony/programming/tv-himalaya-mail";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nix-darwin,
      home-manager,
      fenix,
      catppuccin,
      my-nvim,
      nushell-cfg,
      sops-nix,
      nushell_plugin_crossref,
      wait-for-lsp,
      terminal-browser,
      rushi-config,
      tv-rushi,
      tv-himalaya-mail,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#wutongs-MacBook-Air
      darwinConfigurations = {
        "wutongs-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                (import ./overlays/spacebar.nix)
                (import ./overlays/haskell.nix)
                terminal-browser.overlays.default
                (import ./overlays/aws-sdk-cpp.nix)
                (import ./overlays/protobuf.nix)
                (import ./overlays/nix.nix)
                (import ./overlays/tmux.nix)
                (import ./overlays/fish-foreign-env.nix)
                (import ./overlays/ghostty.nix)
                (import ./overlays/gh.nix)
              ];
              environment.systemPackages = with pkgs; [
                gcc
              ];
            })

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/air.nix
                    ./sing-box
                    ./ddns
                    ./television
                  ];
                };
                extraSpecialArgs = {
                  hostName = "wutongs-MacBook-Air";
                  inherit rushi-config;
                };
                sharedModules = [
                  my-nvim.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  rushi-config.homeManagerModules.default
                  tv-rushi.homeManagerModules."aarch64-darwin".default
                  #tv-himalaya-mail.homeManagerModules."aarch64-darwin".default
                ];
                backupFileExtension = "hm-backup";
              };

            }
          ];
        };
        "Tonys-Mac-mini-M4" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                (import ./overlays/spacebar.nix)
                terminal-browser.overlays.default
                (import ./overlays/aws-sdk-cpp.nix)
                (import ./overlays/protobuf.nix)
                (import ./overlays/nix.nix)
                (import ./overlays/tmux.nix)
                (import ./overlays/fish-foreign-env.nix)
                (import ./overlays/ghostty.nix)
              ];
              environment.systemPackages = with pkgs; [
                gcc
                libiconv
              ];
              # The ssh tunnel to nixos-pro5000 moved to a per-user launchd
              # agent in ssh/mini.nix (domain = "user"), so it starts on
              # headless SSH logins instead of a GUI login.
              launchd.daemons.nfs-pro5000 = {
                # Mount the nixos-pro5000 NFS share (10.0.0.6:/home/tony/nfs,
                # the server-side /export) at /Volumes/pro5000. The script is
                # idempotent: it skips the mount when the share is already
                # mounted. If the network is not up at boot, the next
                # StartInterval attempt performs the mount.
                #
                # The guard uses `grep -F` instead of awk: the system
                # /usr/bin/awk cannot parse a backslash-escaped slash in a
                # regex literal, so the old awk guard always died with a
                # syntax error and the daemon remounted every 5 minutes,
                # stacking shadowed NFS mount entries on /Volumes/pro5000.
                script = ''
                  /bin/mkdir -p /Volumes/pro5000
                  # This macOS has no /bin/mount or /usr/bin/mount; the
                  # mount utility is /sbin/mount.
                  node="10.0.0.6:/home/tony/nfs"
                  mountpoint="/Volumes/pro5000"
                  if ! /sbin/mount | /usr/bin/grep -F -q "$node on $mountpoint "; then
                    /sbin/mount -t nfs -o vers=3 "$node" "$mountpoint"
                  fi
                '';
                serviceConfig = {
                  # Runs at load and retries every 5 minutes.
                  StartInterval = 300;
                  StandardOutPath = "/tmp/nfs-pro5000.mount.out";
                  StandardErrorPath = "/tmp/nfs-pro5000.mount.err";
                };
              };
            })

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/mini.nix
                    ./television
                  ];
                };
                extraSpecialArgs = {
                  hostName = "Tonys-Mac-mini-M4";
                  inherit rushi-config;
                };
                sharedModules = [
                  my-nvim.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  rushi-config.homeManagerModules.default
                  tv-rushi.homeManagerModules."aarch64-darwin".default
                  tv-himalaya-mail.homeManagerModules."aarch64-darwin".default
                ];
                backupFileExtension = "hm-backup";
              };
            }
          ];
        };
      };
    };
}
