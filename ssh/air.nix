{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
        AddKeysToAgent = true;
      };
      nixos = {
        user = "tony";
        hostname = "10.147.17.20";
        identityFile = "~/.ssh/id_ed25519";
      };
      mac = {
        user = "tonywu";
        hostname = "10.147.17.25";
        identityFile = "~/.ssh/id_ed25519";
      };
      macm4 = {
        user = "tony";
        hostname = "10.147.17.145";
        identityFile = "~/.ssh/id_ed25519";
      };
      klt = {
        user = "klt";
        hostname = "10.147.17.146";
        identityFile = "~/.ssh/id_ed25519";
        forwardX11 = true;
      };
      local-mini = {
        user = "tony";
        hostname = "10.0.0.5";
        identityFile = "~/.ssh/id_ed25519";
      };
      mba = {
        user = "tony";
        hostname = "10.147.17.179";
        identityFile = "~/.ssh/id_ed25519";
      };
      nixos-2 = {
        user = "tony";
        hostname = "10.0.0.3";
        proxyJump = "nixos";
      };
      nixos-pro5000 = {
        user = "tony";
        hostname = "10.147.17.8";
      };
    };
  };
}
