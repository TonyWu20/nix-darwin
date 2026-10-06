{
  description = "Example nix-darwin system flake ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    catppuccin.url = "github:catppuccin/nix";
    my-nvim = {
      url = "github:TonyWu20/my-nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nushell-cfg = {
      #nvimdots = { url = "git+file:///Users/tony/Downloads/nvimdots"; };
      url = "github:TonyWu20/nushell_hm_module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell_plugin_crossref = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:TonyWu20/crossref-rs";
    };
    wait-for-lsp = {
      url = "github:TonyWu20/wait-for-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terminal-browser.url = "github:TonyWu20/terminal-browser-flake";
    rushi-config = {
      url = "git+ssh://git@github.com/TonyWu20/rushi-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };
    tv-rushi = {
      url = "github:TonyWu20/tv-rushi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nix-darwin
    , home-manager
    , fenix
    , catppuccin
    , my-nvim
    , nushell-cfg
    , sops-nix
    , nushell_plugin_crossref
    , wait-for-lsp
    , terminal-browser
    , rushi-config
    , tv-rushi
    , ...
    }:
    let
      # Spacebar fails to link with Nix's cctools ld on macOS 26+
      spacebar-overlay = final: prev: {
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
      };
      haskell_overlay = (final: prev: {
        haskellPackages = prev.haskellPackages.override {
          overrides = hFinal: hPrev: {
            tls = prev.haskell.lib.dontCheck hPrev.tls;
          };
        };
        ghc = prev.ghc.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      });
      # The `nix` package (nix < 2.33) links aws-sdk-cpp for S3 binary cache
      # support. The SDK's unit tests auto-run during buildPhase via CMake
      # POST_BUILD (controlled by -DAUTORUN_UNIT_TESTS, not by doCheck).
      # STSProfileCredentialsProviderTest writes its fixture config file to
      # $HOME/.aws, but Nix sets HOME=/homeless-shelter in builds, so the
      # write silently fails and 7 of those tests fail. Keep building the
      # tests, but stop auto-running them in the build sandbox.
      aws_sdk_cpp_overlay = (final: prev: {
        aws-sdk-cpp = prev.aws-sdk-cpp.overrideAttrs (old: {
          cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DAUTORUN_UNIT_TESTS=OFF" ];
        });
      });
      # protobuf's MapImplTest.RandomOrdering expects map iteration order to
      # be randomly seeded per process; in the Nix build sandbox the seed is
      # deterministic, so the test fails (reproducibly) on aarch64-darwin.
      # Skip the unit-test suite. The closure builds several protobuf
      # versions (default plus versioned instances pulled in by other
      # packages, e.g. protobuf-c -> protobuf_33); disable tests on all of
      # them.
      protobuf_overlay = (final: prev: {
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
      });
      # The nix package gates its build on the full test suite: it sets
      # doCheck = true and lists `nix-functional-tests` in checkInputs, so
      # building `nix` (e.g. as a dependency of `cachix`) runs all 201
      # functional tests. For nix 2.31.5+1, nine tests fail
      # deterministically, independent of host, and the gate is still
      # wired in as of nix 2.34.8:
      #   - the version string `2.31.5+1` lands in the test build dir name
      #     (`nix-build-nix-functional-tests-2.31.5+1.drv-0`). The `+`
      #     breaks the shell paths the tests embed in regexes: `5+` parses
      #     as a "one or more 5" quantifier, so the ERE patterns of
      #     `repl` (grep -o -E "$NIX_STORE_DIR/\w*-simple"), `nix-shell`
      #     ([[ $out =~ ${testDir}.* ]]) and `user-envs` (jq regex) never
      #     match; `nix-profile` and `dubious-query` embed the raw path in
      #     expected nix error text, but nix prints the `+`
      #     percent-encoded as `%2B`.
      #   - `binary-cache` and `ca:substitute` abort with SIGABRT: after
      #     the test clears the NAR-info disk cache database,
      #     NarInfoDiskCacheImpl::getCache reaches unreachable() in
      #     src/libstore/nar-info-disk-cache.cc.
      # These are upstream nix bugs. Skip the check gate so building `nix`
      # does not run the broken suite. nixpkgs also pins older nix
      # instances under `nixVersions` (e.g. `nix_2_31`, used by the
      # `cachix` and `hercules-ci` haskell builds). Those instances carry
      # the same gate. Skip it on every derivation in `nixVersions`.
      #
      # Disabling the gate also removes the C closure that the test
      # packages used to pull into the nix build. The haskell builds of
      # `hercules-ci` and `cachix` rely on that closure: the nix `.pc`
      # files need `libblake3` and other C libraries, and pkg-config
      # only finds them if they reach the haskell build inputs. With the
      # gate off, configure fails with
      # "Package libblake3 was not found in the pkg-config search path".
      # The override below restores the C closure as explicit build
      # inputs. It excludes the test packages themselves:
      # `nix-functional-tests` still runs the full suite in its own
      # checkPhase, which fails deterministically on this host.
      nix_overlay = final: prev:
      let
        lib = prev.lib;

          directDeps = p:
            (if builtins.isAttrs p then p.buildInputs or [] else [])
            ++ (if builtins.isAttrs p then p.propagatedBuildInputs or [] else []);

          # Transitive buildInputs closure of the test packages' direct
          # dependencies, i.e. the C closure. The test packages themselves
          # are excluded so their checkPhase stays out of the build plan.
          cClosureOf =
            inst:
            let
              seed = builtins.concatMap directDeps (inst.checkInputs or []);
              dedupName = p:
                if builtins.isAttrs p then lib.getName p
                else builtins.baseNameOf (toString p);
              step = seen:
                let
                  fresh = builtins.filter
                    (x: !builtins.elem (dedupName x) (map dedupName seen))
                    seen;
                  more = builtins.concatMap directDeps fresh;
                in
                if more == [ ] then seen else step (seen ++ more);
            in
            step seed;

          skipGates = inst:
            if builtins.isAttrs inst
            && (inst ? outPath || inst ? outputSpecs)
            then
              inst.overrideAttrs (old: {
                doCheck = false;
                buildInputs = (old.buildInputs or []) ++ cClosureOf old;
              })
            else
              inst;
        in
        {
          nix = skipGates prev.nix;
          nixVersions = prev.nixVersions // builtins.listToAttrs (
            builtins.map (name: {
              inherit name;
              value = skipGates prev.nixVersions.${name};
            }) (builtins.attrNames prev.nixVersions)
          );
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#wutongs-MacBook-Air
      darwinConfigurations = {
        "wutongs-MacBook-Air" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                spacebar-overlay
                haskell_overlay
                terminal-browser.overlays.default
                aws_sdk_cpp_overlay
                protobuf_overlay
                nix_overlay
              ];
              environment.systemPackages = with pkgs; [
                gcc
              ];
            }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/air.nix
                    ./sing-box
                    ./ddns
                    ./television
                  ];
                };
                extraSpecialArgs = {
                  hostName = "wutongs-MacBook-Air";
                  inherit rushi-config;
                };
                sharedModules = [
                  my-nvim.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  rushi-config.homeManagerModules.rushi
                  tv-rushi.homeManagerModules."aarch64-darwin".default
                ];
                backupFileExtension = "hm-backup";
              };

            }
          ];
        };
        "Tonys-Mac-mini-M4" = nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              nixpkgs.overlays = [
                fenix.overlays.default
                nushell_plugin_crossref.overlays.default
                wait-for-lsp.overlays.default
                spacebar-overlay
                terminal-browser.overlays.default
                aws_sdk_cpp_overlay
                protobuf_overlay
                nix_overlay
              ];
              environment.systemPackages = with pkgs; [
                gcc
                libiconv
              ];
              launchd.user.agents.ssh-tunnel-nixos-pro5000 = {
                serviceConfig = {
                  ProgramArguments = [
                    "/usr/bin/ssh"
                    "-NT"
                    "nixos-pro5000"
                  ];
                  # KeepAlive ensures the tunnel automatically restarts if the connection drops
                  KeepAlive = true;
                  RunAtLoad = true;

                  # Optional: Log errors if troubleshooting is needed
                  StandardOutPath = "/tmp/ssh-tunnel-nixos-pro5000.out.log";
                  StandardErrorPath = "/tmp/ssh-tunnel-nixos-pro5000.err.log";
                };
              };
            }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tony = {
                  imports = [
                    ./home.nix
                    ssh/mini.nix
                    ./television
                  ];
                };
                extraSpecialArgs = {
                  hostName = "Tonys-Mac-mini-M4";
                  inherit rushi-config;
                };
                sharedModules = [
                  my-nvim.homeManagerModules.default
                  catppuccin.homeModules.catppuccin
                  nushell-cfg.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  rushi-config.homeManagerModules.rushi
                  tv-rushi.homeManagerModules."aarch64-darwin".default
                ];
                backupFileExtension = "hm-backup";
              };
            }
          ];
        };
      };
    };
}
