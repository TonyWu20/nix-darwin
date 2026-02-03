{ ... }:
{
  programs.ssh = {
    enable = true;
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
        hostname = "10.0.0.2";
        identityFile = "~/.ssh/id_ed25519";
      };
      nix-2 = {
        host = "nixos-2";
        user = "tony";
        hostname = "10.0.0.3";
        identityFile = "~/.ssh/id_ed25519";
      };
      nix-3 = {
        host = "nixos-3";
        user = "tony";
        hostname = "10.0.0.4";
        identityFile = "~/.ssh/id_ed25519";
      };
      local-mini = {
        host = "m1-mini";
        user = "tonywu";
        hostname = "10.0.0.1";
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
