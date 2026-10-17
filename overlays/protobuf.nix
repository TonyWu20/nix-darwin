# protobuf's MapImplTest.RandomOrdering expects map iteration order to
# be randomly seeded per process; in the Nix build sandbox the seed is
# deterministic, so the test fails (reproducibly) on aarch64-darwin.
# Skip the unit-test suite. The closure builds several protobuf
# versions (default plus versioned instances pulled in by other
# packages, e.g. protobuf-c -> protobuf_33); disable tests on all of
# them.
final: prev: {
  protobuf = prev.protobuf.overrideAttrs (old: {
    doCheck = false;
  });
}
// prev.lib.optionalAttrs (prev ? protobuf_33) {
  protobuf_33 = prev.protobuf_33.overrideAttrs (old: { doCheck = false; });
}
// prev.lib.optionalAttrs (prev ? protobuf_34) {
  protobuf_34 = prev.protobuf_34.overrideAttrs (old: { doCheck = false; });
}
// prev.lib.optionalAttrs (prev ? protobuf_35) {
  protobuf_35 = prev.protobuf_35.overrideAttrs (old: { doCheck = false; });
}
