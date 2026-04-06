{ nixpkgs-cc-patch, ... }:
{
  programs.claude-code = {
    enable = true;
    package = nixpkgs-cc-patch.claude-code;
    skills = {
      first-principle = ./first-principles-skill;
      rust-api-doc = ./rust-api-doc;
    };
  };
}
