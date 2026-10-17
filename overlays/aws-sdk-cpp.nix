# The `nix` package (nix < 2.33) links aws-sdk-cpp for S3 binary cache
# support. The SDK's unit tests auto-run during buildPhase via CMake
# POST_BUILD (controlled by -DAUTORUN_UNIT_TESTS, not by doCheck).
# STSProfileCredentialsProviderTest writes its fixture config file to
# $HOME/.aws, but Nix sets HOME=/homeless-shelter in builds, so the
# write silently fails and 7 of those tests fail. Keep building the
# tests, but stop auto-running them in the build sandbox.
final: prev: {
  aws-sdk-cpp = prev.aws-sdk-cpp.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DAUTORUN_UNIT_TESTS=OFF" ];
  });
}
