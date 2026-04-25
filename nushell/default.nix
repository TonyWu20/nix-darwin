{ lib, config, ... }: {
  programs.nushell = {
    extraConfig = builtins.concatStringsSep "\n" [
    ''
      $env.POE_BASE_URL = "https://api.poe.com"
      $env.YUNWU_BASE_URL = "https://yunwu.ai"
      $env.FOXCODE_BASE_URL = "https://code.newcli.com/claude/ultra"
      $env.XCODE_BEST_BASE_URL = "https://xcode.best"
      $env.CLAUDE_ZZ_BASE_URL = "https://claude-zhongzhuan.cloud"
      $env.DEEPSEEK_BASE_URL = "https://api.deepseek.com/anthropic"
      $env.ANTHROPIC_API_KEY = ""
      $env.ANTHROPIC_AUTH_TOKEN = $env.FOXCODE_TOKEN
      $env.ANTHROPIC_BASE_URL = $env.FOXCODE_BASE_URL
    ''
    ''${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: 
        "$env.${lib.toUpper name} = (open ${value.path} | str trim)"
      ) config.sops.secrets)}
    ''
    ];
  };
}
