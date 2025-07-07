{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    catppuccin.url = "github:catppuccin/nix";
    nvimdots = { url = "github:TonyWu20/nvimdots/main"; };
  };

  outputs = { nix-darwin, home-manager, fenix, catppuccin, nvimdots, ... }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#wutongs-MacBook-Air
      darwinConfigurations."wutongs-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ fenix.overlays.default ];
            environment.systemPackages = with pkgs; [

              (fenix.packages.aarch64-darwin.stable.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
                "rust-analyzer"
              ])
              gcc
            ];
          }
          )

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tony = import ./home.nix;
              sharedModules = [
                nvimdots.homeManagerModules.default
                catppuccin.homeModules.catppuccin
              ];
              backupFileExtension = ".backup";
            };

          }
        ];
      };
    };
}
