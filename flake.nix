{
  description = "Example nix-darwin system flake ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-claude-code-patch = {
      url = "github:TonyWu20/nixpkgs/claude-code-patch";
    };
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    catppuccin.url = "github:catppuccin/nix";
    nvimdots = { url = "github:TonyWu20/nvimdots/main"; };
    nushell-cfg.url = "github:TonyWu20/nushell_hm_module";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell_plugin_crossref = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:TonyWu20/crossref-rs";
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
    , nixpkgs-claude-code-patch
    , ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#wutongs-MacBook-Air
      darwinConfigurations = {
        "wutongs-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ fenix.overlays.default ];
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
                  nixpkgs-cc-patch = import nixpkgs-claude-code-patch { system = "aarch64-darwin"; config.allowUnfree = true; };
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
                backupFileExtension = "backup";
              };

            }
          ];
        };
        "Tonys-Mac-mini-M4" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ fenix.overlays.default ];
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
                  nixpkgs-cc-patch = import nixpkgs-claude-code-patch { system = "aarch64-darwin"; config.allowUnfree = true; };
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
                backupFileExtension = "backup";
              };
            }
          ];
        };
      };
    };
}
