# Skip the check phases of haskell tls and ghc.
final: prev: {
  haskellPackages = prev.haskellPackages.override {
    overrides = hFinal: hPrev: {
      tls = prev.haskell.lib.dontCheck hPrev.tls;
    };
  };
  ghc = prev.ghc.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
