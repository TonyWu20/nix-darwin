{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    skills = {
      first-principle = ./first-principles-skill;
      #rust-api-doc = ./rust-api-doc;
      #humanizer = ./humanizer;
      #humanizer-zh = ./humanizer-zh;
      socrates-skill = ./socrates-skill;
    };
  };
}
