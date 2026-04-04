{ config, ... }: {
  programs.nushell = {
    extraConfig = ''
      $env.YUNWU_TOKEN = (open ${config.sops.secrets.yunwu_claude_api.path})
      $env.POE_TOKEN = (open ${config.sops.secrets.poe_chatbot_api.path})
      $env.FOXCODE_TOKEN = (open ${config.sops.secrets.foxcode_claude_token.path})
      $env.POE_BASE_URL = "https://api.poe.com"
      $env.YUNWU_BASE_URL = "https://yunwu.ai"
      $env.FOXCODE_BASE_URL = "https://code.newcli.com/claude/ultra"
      $env.ANTHROPIC_API_KEY = ""
      $env.ANTHROPIC_AUTH_TOKEN = $env.FOXCODE_TOKEN
      $env.ANTHROPIC_BASE_URL = $env.FOXCODE_BASE_URL
    '';
  };
}
