final: prev: {
  gh = prev.gh.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
