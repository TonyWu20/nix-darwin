{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets/my_secrets.yaml;
    age.sshKeyPaths = [ "/Users/tony/.ssh/id_ed25519" ];
    age.generateKey = false;
    secrets = {
      poe_chatbot_api = { };
      yunwu_token = { };
      foxcode_token = { };
      xcode_best_claude_token = { };
      claude_zz_token = { };
      telegram_bot_token = { };
      telegram_user_id = { };
      discord_bot_token = { };
      discord_channel_id = { };
      discord_inspect_channel_id = { };
      discord_notify_user_ids = { };
      discord_summary_channel_id = { };
      deepseek_api_key = { };
      mineru_token = { };
      duckdns_token = { };
      # VLESS + Reality server credentials for sing-box (see sing-box/).
      vless_uuid = { };
      vless_private_key = { };
      vless_short_id = { };
      # huggingface token
      hf_token = { };
    };
  };
}
