{
  description = "Pico HSM - Hardware Security Module for Raspberry Pi Pico";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Source with submodules
    pico-hsm-src = {
      url = "git+https://github.com/polhenarejos/pico-hsm?submodules=1";
      flake = false;
    };

    pico-sdk = {
      url = "git+https://github.com/raspberrypi/pico-sdk?ref=refs/tags/2.1.0&submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, pico-hsm-src, pico-sdk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Load configuration from nix/config.nix
        # Edit that file to change VID/PID/board settings
        config = import ./nix/config.nix;

        mkPicoHsm = {
          vid ? config.vid,
          pid ? config.pid,
          board ? config.board,
        }:
        pkgs.stdenv.mkDerivation {
          pname = "pico-hsm";
          version = "6.2";

          src = pico-hsm-src;

          nativeBuildInputs = with pkgs; [
            cmake
            gcc-arm-embedded
            python3
            python3Packages.cryptography
            git
            picotool
            gnumake
          ];

          buildInputs = with pkgs; [
            newlib
          ];

          # Don't use the cmake build hook - we need to run cmake manually
          # to avoid Nix overriding the ARM toolchain
          dontUseCmakeConfigure = true;

          # The pico SDK expects certain environment variables
          configurePhase = ''
            runHook preConfigure
            export PICO_SDK_PATH="${pico-sdk}"
            export HOME=$TMPDIR

            cmake -B build -S . \
              -DPICO_SDK_PATH="${pico-sdk}" \
              -DPICO_BOARD="${board}" \
              -DUSB_VID="${vid}" \
              -DUSB_PID="${pid}" \
              -DPICO_SDK_FETCH_FROM_GIT=OFF
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            make -C build -j$NIX_BUILD_CORES
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/firmware
            cp -v build/*.uf2 $out/firmware/ 2>/dev/null || true
            cp -v build/*.elf $out/firmware/ 2>/dev/null || true
            cp -v build/*.bin $out/firmware/ 2>/dev/null || true
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Hardware Security Module (HSM) for Raspberry Pi Pico";
            homepage = "https://github.com/polhenarejos/pico-hsm";
            license = licenses.gpl3;
            platforms = platforms.all;
          };
        };

      in
      {
        # Default package with default VID/PID
        packages.default = mkPicoHsm { };

        # Pico 2 variant
        packages.pico2 = mkPicoHsm { board = "pico2"; };

        # Function to build with custom VID/PID
        lib.mkPicoHsm = mkPicoHsm;

        # Development shell with all build dependencies
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            gcc-arm-embedded
            python3
            python3Packages.cryptography
            git
            picotool
            opensc  # for testing
          ];

          shellHook = ''
            echo "Pico HSM development shell"
            echo "Build with: mkdir build && cd build && cmake .. -DUSB_VID=0x1234 -DUSB_PID=0x5678 && make"
          '';
        };
      }
    );
}
