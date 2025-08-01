{ pkgs, ... }:
{
  imports = [
    ./yabai
    ./spacebar
    ./homebrew
  ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    with pkgs;[
      vim
      neovim
      skhd
      fish
      nushell
      zoxide
    ];

  nixpkgs.config.allowUnfree = true;


  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.enable = false;

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = "tony";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    font-awesome_5
    source-sans-pro
    noto-fonts
    noto-fonts-cjk-sans
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  users.users.tony.home = "/Users/tony";
  users.users.tony.shell = pkgs.fish;
  users.users.tony.uid = 501;
  users.knownUsers = [ "tony" ];

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.2;
    expose-animation-duration = 0.2;
    tilesize = 48;
    show-recents = false;
    show-process-indicators = true;
    orientation = "left";
  };
}
