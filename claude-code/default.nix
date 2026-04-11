{ nixpkgs-cc-patch, pkgs, ... }:
{
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
      notify =
        (if pkgs.stdenv.isDarwin then
          ''
            #!/usr/bin/env bash
            read -r input
            message=$(echo "$input" | jq -r '.message // "Claude needs input"')
            # Use terminal-notifier or osascript
            osascript -e "display notification \"$message\" with title \"Claude Code\""
          ''
        else "");
    };
  };
}
