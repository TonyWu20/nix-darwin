{ config, ... }:
{
  programs.nushell = {
    extraConfig = ''
      $env.YUNWU_TOKEN = (open ${config.sops.secrets.yunwu_claude_api.path})
      $env.POE_TOKEN = (open ${config.sops.secrets.poe_chatbot_api.path})
      $env.POE_BASE_URL = https://api.poe.com
      $env.YUNWU_BASE_URL = https://yunwu.ai
      $env.ANTHROPIC_API_KEY = ""
      $env.ANTHROPIC_AUTH_TOKEN = $env.YUNWU_TOKEN
      $env.ANTHROPIC_BASE_URL = $env.YUNWU_BASE_URL
    '';
  };
}
