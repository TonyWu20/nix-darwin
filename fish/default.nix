{ lib, pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.concatStringsSep "\n" [
      ''
        fish_vi_key_bindings
        zoxide init fish | source
        set -gx FZF_DEFAULT_COMMAND 'fd --type file -HI -E .git --color=always'
        set -gx FZF_PREVIEW_FILE_CMD 'bat --style=header,numbers,grid --line-range :300 --color=always'
        set -gx FZF_PREVIEW_DIR_CMD 'eza -l --git --no-permissions --icons --no-user --level=2 -T '
        set -U FZF_TMUX 0
        set -U FZF_COMPLETE 1
        set -ga PATH ~/.cargo/bin/
        source ${pkgs.fish}/share/fish/completions/rsync.fish
        /opt/homebrew/bin/brew shellenv |source
      ''
      ''
        # Automatically export sops secrets in UPPERCASE
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: 
          "set -gx ${lib.toUpper name} (cat ${value.path})"
        ) config.sops.secrets)}
      ''
      ''
        set -gx POE_BASE_URL https://api.poe.com
        set -gx YUNWU_BASE_URL https://yunwu.ai
        set -gx FOXCODE_BASE_URL https://code.newcli.com/claude/ultra
        set -gx XCODE_BEST_BASE_URL https://xcode.best
        set -gx CLAUDE_BASE_URL https://claude-zhongzhuan.cloud
        set -gx ANTHROPIC_API_KEY ""
        set -gx ANTHROPIC_AUTH_TOKEN $CLAUDE_ZZ_TOKEN
        set -gx DEEPSEEK_BASE_URL https://api.deepseek.com/anthropic
      ''
    ];
    preferAbbrs = true;
    shellAbbrs = {
      vim = "nvim";
      ls = "eza";
    };
    functions = {
      num_kpt_geom = {
        argumentNames = [ "cell" ];
        body = "sed 's/\r$//g' $cell | rg -UP \"(?s)(?<=%BLOCK KPOINTS_LIST\n).*(?=%ENDBLOCK KPOINTS_LIST)\"  |wc -l";
        description =
          "Count the lines inside block KPOINTS_LIST to get the number of kpoints in non-spectral task cell.
# Args:
- cell: path to the cell that contains block KPOINTS_LIST.";
      };
      num_kpt_spec = {
        argumentNames = [ "cell" ];
        body = "sed 's/\r$//g' $cell | rg -UP \"(?s)(?<=%BLOCK SPECTRAL_KPOINT_LIST\n).*(?=%ENDBLOCK SPECTRAL_KPOINT_LIST)\"  |wc -l";
        description =
          "Count the lines inside block SPECTRAL_KPOINT_LIST to get the number of kpoints in spectral task cell.
# Args:
- cell: path to the cell that contains block SPECTRAL_KPOINT_LIST.";
      };
    };
  };
  home.packages = with pkgs; [
    fishPlugins.z
    fishPlugins.fzf
    fishPlugins.done
    fishPlugins.bass
    fishPlugins.forgit
    fishPlugins.fifc
  ];
}


