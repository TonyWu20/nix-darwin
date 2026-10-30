# nixpkgs builds fish-foreign-env from a 2023 upstream commit
# (version 0-unstable-2023-08-23). That fenv script predates fish 4.9:
# every `fenv` call (nix-darwin `programs.fish` generates them in
# /etc/fish/config.fish) errors at startup on fish 4.9 with
# "$@ is not supported" whenever the environment contains a variable
# whose name is not a valid fish variable name, e.g. tmux global env
# vars like `@cpu_ram_text` (see ./tmux). Upstream fixed this on
# 2026-07-06 by skipping such names:
#   https://github.com/oh-my-fish/plugin-foreign-env/commit/b693237c3027b81ac3760d60d159d2be4925ed1c
# Re-pin the package to that commit until nixpkgs moves its own pin.
# The nixpkgs preInstall sed (plain `bash` -> Nix bash path) still
# applies: the fixed script keeps the same `bash -c` line.
final: prev: {
  fishPlugins = prev.fishPlugins // {
    "foreign-env" = prev.fishPlugins."foreign-env".overrideAttrs (old: {
      version = "0-unstable-2026-07-06";
      name = "fishplugin-foreign-env-0-unstable-2026-07-06";
      src = prev.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "plugin-foreign-env";
        rev = "b693237c3027b81ac3760d60d159d2be4925ed1c";
        hash = "sha256-JyAFxYkPQZs4TfVfBVPKa202SXsAZCyCLzVW+6/PASA=";
      };
    });
  };
}
