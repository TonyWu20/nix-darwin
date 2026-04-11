{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets/my_secrets.yaml;
    age.sshKeyPaths = [ "/Users/tony/.ssh/id_ed25519" ];
    age.generateKey = false;
    secrets.poe_chatbot_api = { };
    secrets.yunwu_claude_api = { };
    secrets.foxcode_claude_token = { };
    secrets.xcode_best_claude_token = { };
    secrets.claude_zz_token = { };
  };
}
