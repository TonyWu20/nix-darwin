{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets/my_secrets.yaml;
    age.sshKeyPaths = [ "/Users/tony/.ssh/id_ed25519" ];
    age.generateKey = false;
    secrets = {
      poe_chatbot_api = { };
      yunwu_claude_api = { };
      foxcode_claude_token = { };
      xcode_best_claude_token = { };
      claude_zz_token = { };
      telegram_bot_token = { };
      telegram_user_id = { };
    };
  };
}
