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
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    catppuccin.url = "github:catppuccin/nix";
    nvimdots = { url = "github:TonyWu20/nvimdots/main"; inputs.nixpkgs.follows = "nixpkgs"; };
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
    pi.url = "github:lukasl-dev/pi.nix";
    pi-config.url = "git+ssh://git@github.com/TonyWu20/pi-config";
  };

  outputs =
    { nix-darwin
    , home-manager
    , fenix
    , catppuccin
    , nvimdots
    , nushell-cfg
    , sops-nix
    , nushell_plugin_crossref
    , wait-for-lsp
    , pi
    , pi-config
    , ...
    }:
    let
      # Spacebar fails to link with Nix's cctools ld on macOS 26+
      spacebar-overlay = final: prev: {
        spacebar = prev.spacebar.overrideAttrs (old: {
          buildPhase = ''
            runHook preBuild
            mkdir -p bin
            # Use system Xcode clang, bypassing Nix's cctools ld which
            # crashes on macOS 26+
            /usr/bin/clang src/manifest.m -std=c99 -Wall -DDEBUG -g -O0 \
              -fvisibility=hidden -mmacosx-version-min=10.13 \
              -B/Library/Developer/CommandLineTools/usr/bin \
              -F/System/Library/PrivateFrameworks \
              -framework Carbon -framework Cocoa -framework CoreServices \
              -framework SkyLight -framework ScriptingBridge -framework IOKit \
              -o bin/spacebar
            runHook postBuild
          '';
          installPhase = old.installPhase or ''
            runHook preInstall
            mkdir -p $out/bin
            cp bin/spacebar $out/bin/
            runHook postInstall
          '';
        });
        # zvbi: fix SDK 14.4+ incompatibilities on macOS
        zvbi = prev.zvbi.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=macro-redefined";
          configureFlags = (old.configureFlags or [ ]) ++ [ "--without-x" ];
        });
        # yabai uses cctools ld which crashes on macOS 26+, use system linker
        yabai = prev.yabai.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -B/Library/Developer/CommandLineTools/usr/bin";
        });
      };
      nvim_overlay = (final: prev: {
        neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
          # Disable tests to bypass parallel harness crashes entirely
          python3 = final.python313;
          doCheck = false;
        });
      });
      haskell_overlay = (final: prev: {
        haskellPackages = prev.haskellPackages.override {
          overrides = hFinal: hPrev: {
            tls = prev.haskell.lib.dontCheck hPrev.tls;
          };
        };
      });
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#wutongs-MacBook-Air
      darwinConfigurations = {
        "wutongs-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                # Pin default Python to 3.13 to avoid untokenize/docformatter incompatibility
                (final: prev: {
                  python3 = final.python313;
                  python3Packages = final.python313Packages;
                })
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                spacebar-overlay
                nvim_overlay
                haskell_overlay
              ];
              environment.systemPackages = with pkgs; [
                gcc
              ];
            }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/air.nix
                  ];
                };
                extraSpecialArgs = {
                  hostName = "wutongs-MacBook-Air";
                  inherit pi-config;
                };
                sharedModules = [
                  nvimdots.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  pi.homeModules.default
                  (pi-config.piModules.homeManager { system = "aarch64-darwin"; })
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
                # Pin default Python to 3.13 to avoid untokenize/docformatter incompatibility
                (final: prev: {
                  python3 = final.python313;
                  python3Packages = final.python313Packages;
                })
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                spacebar-overlay
              ];
              environment.systemPackages = with pkgs; [
                gcc
                libiconv
              ];
            }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/mini.nix
                  ];
                };
                extraSpecialArgs = {
                  hostName = "Tonys-Mac-mini-M4";
                  inherit pi-config;
                };
                sharedModules = [
                  nvimdots.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  pi.homeModules.default
                  (pi-config.piModules.homeManager { system = "aarch64-darwin"; })
                ];
                backupFileExtension = "hm-backup";
              };
            }
          ];
        };
      };
    };
}
