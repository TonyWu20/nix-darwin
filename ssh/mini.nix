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
      j = {
        user = "ohio";
        hostname = "10.147.17.31";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # Keep the SSH tunnel to nixos-pro5000 alive on this headless mini.
  # The per-user (background) launchd domain makes the agent start on SSH
  # logins without a GUI session. The host `nixos-pro5000` resolves via
  # the ssh settings above.
  launchd.agents."ssh-tunnel-nixos-pro5000" = {
    enable = true;
    domain = "user";
    config = {
      # KeepAlive restarts the tunnel if the connection drops.
      ProgramArguments = [ "/usr/bin/ssh" "-NT" "nixos-pro5000" ];
      RunAtLoad = true;
      KeepAlive = true;
      # Log output if the tunnel misbehaves.
      StandardOutPath = "/tmp/ssh-tunnel-nixos-pro5000.out.log";
      StandardErrorPath = "/tmp/ssh-tunnel-nixos-pro5000.err.log";
    };
  };
}
