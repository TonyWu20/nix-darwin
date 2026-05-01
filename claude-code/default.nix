{ nixpkgs-cc-patch, pkgs, ... }:
{
  home.packages = with pkgs;[
    claude-code-router
  ];
  programs.claude-code = {
    enable = true;
    package = nixpkgs-cc-patch.claude-code;
    skills = {
      first-principle = ./first-principles-skill;
      rust-api-doc = ./rust-api-doc;
      humanizer = ./humanizer;
      humanizer-zh = ./humanizer-zh;
    };
    hooks = {
      five_mins = builtins.readFile ./five_min.sh;
    };
  };
}
