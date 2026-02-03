{ ... }:
{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      github = {
        host = "github.com";
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      nix = {
        host = "nix";
        user = "tony";
        hostname = "10.147.17.20";
        identityFile = "~/.ssh/id_ed25519";
      };
      mac-mini = {
        host = "mac";
        user = "tonywu";
        hostname = "10.147.17.25";
        identityFile = "~/.ssh/id_ed25519";
      };
      klt = {
        host = "klt";
        user = "klt";
        hostname = "10.147.17.146";
        identityFile = "~/.ssh/id_ed25519";
        forwardX11 = true;
      };
      local-mini = {
        host = "local-mini";
        user = "tonywu";
        hostname = "10.0.0.5";
        identityFile = "~/.ssh/id_ed25519";
      };
      mba = {
        host = "mba";
        user = "tony";
        hostname = "10.147.17.179";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
