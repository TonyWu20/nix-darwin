{ lib, pkgs, config, hostName, ... }: {
  programs.fish = {
    enable = true;
    # fish 4.1+ sends a Primary Device Attribute (DA1) query at startup and
    # waits up to 10 seconds (fish 4.6+) for a reply. Terminals that do not
    # reply (macOS Terminal.app, or a tmux pane while tmux outer-terminal DA
    # responses are in flight) make every fish startup hang 10 seconds and
    # print a warning. Turning off the query-terminal feature removes the
    # wait. See fish docs "terminal-compatibility" and
    # https://github.com/fish-shell/fish-shell/issues/12571 .
    shellInit = ''
      if not set -q fish_features
        set -Ua fish_features no-query-term
      end
    '';
    interactiveShellInit = builtins.concatStringsSep "\n" [
      ''
        fish_vi_key_bindings
        zoxide init fish | source
        set -gx FZF_DEFAULT_COMMAND 'fd --type file -HI -E .git --color=always'
        set -gx FZF_PREVIEW_FILE_CMD 'bat --style=header,numbers,grid --line-range :300 --color=always'
        set -gx FZF_PREVIEW_DIR_CMD 'eza -l --git --no-permissions --icons --no-user --level=2 -T '
        set -U FZF_TMUX 0
        set -U FZF_COMPLETE 1
        set -ga PATH ~/.cargo/bin
        source ${
          pkgs.runCommand "rsync-fish-completion" { } ''
            ${pkgs.fish}/bin/fish --no-config -c 'status get-file completions/rsync.fish' > $out
          ''
        }
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
        set -gx ANTHROPIC_AUTH_TOKEN $DEEPSEEK_TOKEN
        set -gx DEEPSEEK_BASE_URL https://api.deepseek.com/anthropic
        set -gx ANTHROPIC_BASE_URL $DEEPSEEK_BASE_URL
      ''
      (if hostName == "Tonys-Mac-mini-M4" then
        "set -gx DISCORD_BOT_HOST 0.0.0.0:9876"
      else
        ''set -gx DISCORD_BOT_HOST 10.147.17.145:9876
          set -gx DISCORD_BOT_REMOTE true
        '')
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
    (fishPlugins.bass.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ gnumake ];
      doCheck = false;
    }))
    fishPlugins.forgit
    fishPlugins.fifc
  ];
}


