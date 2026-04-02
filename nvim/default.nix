{ pkgs, ... }:
{
  programs.neovim = {
    package = pkgs.neovim-unwrapped.overrideAttrs (old: rec{
      version = "0.11.6";
      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        tag = "v${version}";
        hash = "sha256-GdfCaKNe/qPaUV2NJPXY+ATnQNWnyFTFnkOYDyLhTNg=";
      };
    });
    enable = true;
    defaultEditor = true;
    nvimdots = {
      enable = true;
      #setBuildEnv=true;
      #withBuildTools=true;
    };
    # enable = true;
    extraPackages = with pkgs; [
      go
      python3
    ];
  };
}
