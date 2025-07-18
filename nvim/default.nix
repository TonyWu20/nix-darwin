{ config, lib, ... }:
let
  cfg = config.programs.neovim.nvimdots;
  inherit (lib) flip warn const;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.strings) concatStringsSep versionOlder versionAtLeast;
  inherit (lib.types) listOf coercedTo package functionTo;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    nvimdots= {
    	enable=true;
	setBuildEnv=true;
	withBuildTools=true;
    };
    # enable = true;
    # extraPackages = with pkgs; [
    #   go
    #   python3
    # ];
  };
}
