# nixpkgs ships ghostty-bin 1.3.1. The latest Ghostty release is
# 1.4.0. The package fetches a versioned DMG from
# release.files.ghostty.org. The bump replaces version and src only.
# Both hosts are aarch64-darwin. ghostty/default.nix selects
# ghostty-bin for Darwin. This override upgrades the terminal on
# both machines.
#
# The source-built ghostty package targets Linux only in this
# nixpkgs. It stays at 1.3.1.
final: prev: {
  ghostty-bin = prev.ghostty-bin.overrideAttrs (old: {
    version = "1.4.0";
    src = prev.fetchurl {
      url = "https://release.files.ghostty.org/1.4.0/Ghostty.dmg";
      hash = "sha256-OgIHXb0kMY13hCavQd7lUH1T7MRXjt6WkS7Jzm0Y0+g=";
    };
  });
}
