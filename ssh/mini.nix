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
      };
      nixos = {
        user = "tony";
        hostname = "10.0.0.2";
        identityFile = "~/.ssh/id_ed25519";
      };
      nixos-2 = {
        user = "tony";
        hostname = "10.0.0.3";
        identityFile = "~/.ssh/id_ed25519";
      };
      nixos-3 = {
        user = "tony";
        hostname = "10.0.0.4";
        identityFile = "~/.ssh/id_ed25519";
      };
      m1-mini = {
        user = "tonywu";
        hostname = "10.0.0.1";
        identityFile = "~/.ssh/id_ed25519";
      };
      mba = {
        user = "tony";
        hostname = "10.147.17.179";
        identityFile = "~/.ssh/id_ed25519";
      };
      nixos-pro5000 = {
        user = "tony";
        hostname = "10.0.0.6";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
