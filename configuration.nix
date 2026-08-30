{ pkgs, ... }:
{
  imports = [
    ./yabai
    ./spacebar
    ./homebrew
  ];
  environment = {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    systemPackages =
      with pkgs;[
        vim
        neovim
        skhd
        fish
        nushell
        zoxide
        fontconfig
        # VLESS+Reality VPN server for friend's GFW bypass
        sing-box
        jaq
      ];
    # Ensure the environment variables are correctly inherited by the shells
    variables = {
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      CURL_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    # man-db's `make check` runs its man-page tests in parallel; on macOS 26.1
    # the test-harness bash subshells intermittently SIGSEGV inside macOS's
    # CFPreferences/os_log locale code (KERN_INVALID_ADDRESS in
    # _os_log_preferences_refresh), failing the build with a random test each
    # time (e.g. "FAIL: man8/catman.8", exit 139). This is an OS-level race,
    # not a man-db bug. Disable the check phase (nixpkgs previously kept
    # doCheck off on darwin for this class of failure).
    (final: prev: {
      man-db = prev.man-db.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];
  nix = {
    enable = false;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
      # Force nix-daemon to use the Nix certificate bundle
      ssl-cert-file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      extra-substituters = [
        "https://pi.cachix.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

  };
  programs = {

    # Enable alternative shell support in nix-darwin.
    fish.enable = true;
  };

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
