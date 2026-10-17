# nixpkgs ships tmux 3.7b; pin tmux to the 3.8 release line so
# both hosts get it without waiting for the nixpkgs default to
# move. The fetch uses fetchFromGitHub (fetchzip) like the
# nixpkgs package does, so the hash is the recursive hash of
# the unpacked source tree. The 3.8 configure requires an
# explicit jemalloc decision; nixpkgs answers it with
# --enable-jemalloc on darwin, mirrored here.
final: prev: {
  tmux = prev.tmux.overrideAttrs (old: {
    version = "3.8";
    src = prev.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      tag = "3.8";
      hash = "sha256-pv2wlr3coo+E0pfpb58giJJQn9PGgMFqtVA6nk+9JdE=";
    };
    buildInputs = old.buildInputs
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [ prev.jemalloc ];
    configureFlags = old.configureFlags
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [ "--enable-jemalloc" ];
  });
}
