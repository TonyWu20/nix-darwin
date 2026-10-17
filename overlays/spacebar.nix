# Spacebar fails to link with Nix's cctools ld on macOS 26+
final: prev: {
  spacebar = prev.spacebar.overrideAttrs (old: {
    buildPhase = ''
      runHook preBuild
      mkdir -p bin
      # Use system Xcode clang, bypassing Nix's cctools ld which
      # crashes on macOS 26+
      /usr/bin/clang src/manifest.m -std=c99 -Wall -DDEBUG -g -O0 \
        -fvisibility=hidden -mmacosx-version-min=10.13 \
        -B/Library/Developer/CommandLineTools/usr/bin \
        -F/System/Library/PrivateFrameworks \
        -framework Carbon -framework Cocoa -framework CoreServices \
        -framework SkyLight -framework ScriptingBridge -framework IOKit \
        -o bin/spacebar
      runHook postBuild
    '';
    installPhase = old.installPhase or ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/spacebar $out/bin/
      runHook postInstall
    '';
  });
  # zvbi: fix SDK 14.4+ incompatibilities on macOS
  zvbi = prev.zvbi.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=macro-redefined";
    configureFlags = (old.configureFlags or [ ]) ++ [ "--without-x" ];
  });
  # yabai uses cctools ld which crashes on macOS 26+, use system linker
  yabai = prev.yabai.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -B/Library/Developer/CommandLineTools/usr/bin";
  });
}
