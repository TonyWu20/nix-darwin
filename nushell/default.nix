{ config, ... }: {
  programs.nushell = {
    extraConfig = ''
      $env.YUNWU_TOKEN = (open ${config.sops.secrets.yunwu_claude_api.path})
      $env.POE_TOKEN = (open ${config.sops.secrets.poe_chatbot_api.path})
      $env.FOXCODE_TOKEN = (open ${config.sops.secrets.foxcode_claude_token.path})
      $env.XCODE_BEST_TOKEN = (open ${config.sops.secrets.xcode_best_claude_token.path})
      $env.POE_BASE_URL = "https://api.poe.com"
      $env.YUNWU_BASE_URL = "https://yunwu.ai"
      $env.FOXCODE_BASE_URL = "https://code.newcli.com/claude/ultra"
      $env.XCODE_BEST_BASE_URL = "https://xcode.best"
      $env.ANTHROPIC_API_KEY = ""
      $env.ANTHROPIC_AUTH_TOKEN = $env.FOXCODE_TOKEN
      $env.ANTHROPIC_BASE_URL = $env.FOXCODE_BASE_URL
      $env.TELEGRAM_BOT_TOKEN = (open ${config.sops.secrets.telegram_bot_token.path})
      $env.TELEGRAM_CHAT_ID = (open ${config.sops.secrets.telegram_user_id.path})
      $env.DISCORD_CHANNEL_ID = (open ${config.sops.secrets.discord_claude_channel_id.path})
      $env.DISCORD_INSPECT_CHANNEL_ID = (open ${config.sops.secrets.discord_inspect_channel_id.path})
      $env.DISCORD_BOT_TOKEN = (open ${config.sops.secrets.discord_bot_token.path})
      $env.DISCORD_NOTIFY_USER_IDS = (open ${config.sops.secrets.discord_notify_user_ids.path})
    '';
  };
}
