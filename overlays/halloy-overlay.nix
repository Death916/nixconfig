self: super:
let
  rustNightly = super.rust-bin.nightly.latest.default.override {
    extensions = [
      "rust-src"
      "rustc-dev"
    ];
  };
  nightlyRustPlatform = super.makeRustPlatform {
    cargo = rustNightly;
    rustc = rustNightly;
  };
in
{
  halloy = nightlyRustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.6";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      # sha256 = "";
    };

    RUSTC_BOOTSTRAP = 1;

    # Add doc_cfg to allowed features
    RUSTFLAGS = "-Z allow-features=edition2024,avx512_target_feature,stdarch_x86_avx512,doc_cfg";

    postPatch = ''
      # Add feature flags to all relevant crates
      find . -name '*.rs' -exec sed -i '1i #![feature(avx512_target_feature,stdarch_x86_avx512,doc_cfg)]' {} \;

      # Add cargo-features to Cargo.toml files
      find . -name Cargo.toml -exec sh -c '
        if ! grep -q "cargo-features" {}; then
          sed -i "1i cargo-features = [\"edition2024\"]" {}
        fi
      ' \;
    '';

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "winit-0.30.8" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
        "dpi-0.1.1" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
      };
    };

    nativeBuildInputs = with super; [
      pkg-config
      makeWrapper
    ];

    buildInputs = with super; [
      libxkbcommon
      openssl
      vulkan-loader
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      wayland
      alsa-lib.dev
    ];

    # Add this postInstall phase to set up proper library paths
    postInstall = ''
      wrapProgram $out/bin/halloy \
        --prefix LD_LIBRARY_PATH : ${
          super.lib.makeLibraryPath [
            super.wayland
            super.libxkbcommon
            super.vulkan-loader
            super.alsa-lib
            super.openssl
          ]
        }
    '';

    meta = with super.lib; {
      description = "Halloy IRC Client";
      homepage = "https://github.com/squidowl/halloy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}
