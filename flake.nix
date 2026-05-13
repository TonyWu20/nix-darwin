{
  description = "Example nix-darwin system flake ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    catppuccin.url = "github:catppuccin/nix";
    #nvimdots = { url = "github:TonyWu20/nvimdots/main"; };
    nvimdots = { url = "git+file:///Users/tony/Downloads/nvimdots"; };
    nushell-cfg.url = "github:TonyWu20/nushell_hm_module";
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
    , ...
    }:
    let
      claude-code-rev = "v2.1.138";

      claude-code-overlay = final: prev:
        let
          stdenv = final.stdenvNoCC;
          baseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
          platformKey = "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
        in
        {
          claude-code =
            prev.claude-code.overrideAttrs
              (old: rec {
                version = final.lib.removePrefix "v" claude-code-rev;
                src = final.fetchurl {
                  url = "${baseUrl}/${version}/${platformKey}/claude";
                  sha256 = "sha256-dZ0jzmJhk8ibyLNcXGyoqeM7nC5QTuFD5M0RmYh3QJc=";
                };
              });
        };
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
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                claude-code-overlay
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
                };
                sharedModules = [
                  nvimdots.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  {
                    extraPlugins = [
                      nushell_plugin_crossref.packages.aarch64-darwin.nu_plugin_crossref
                    ];
                  }
                  sops-nix.homeManagerModules.sops
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
                claude-code-overlay
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
                };
                sharedModules = [
                  nvimdots.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  # {
                  #   extraPlugins = [
                  #     nushell_plugin_crossref.packages.aarch64-darwin.nu_plugin_crossref
                  #   ];
                  # }
                  sops-nix.homeManagerModules.sops
                ];
                backupFileExtension = "hm-backup";
              };
            }
          ];
        };
      };
    };
}
