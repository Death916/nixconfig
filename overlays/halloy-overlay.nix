self: super:
let
  # Use latest nightly Rust with all required features
  rustNightly = super.rust-bin.nightly.latest.default.override {
    extensions = [ "rust-src" "rustc-dev" ];
  };
  nightlyRustPlatform = super.makeRustPlatform {
    cargo = rustNightly;
    rustc = rustNightly;
  };
in {
  halloy = nightlyRustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.5";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };

    RUSTC_BOOTSTRAP = 1;
    RUSTFLAGS = "-Z allow-features=edition2024,doc_cfg,stdsimd,avx512_target_feature,stdarch_x86_avx512";

    postPatch = ''
      # Add required feature flags to all relevant crates
      find . -name '*.rs' -exec sed -i '1i #![feature(stdsimd,avx512_target_feature,stdarch_x86_avx512)]' {} \;
      
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

    nativeBuildInputs = with super; [ pkg-config ];
    
    buildInputs = with super; [
      libxkbcommon
      openssl
      vulkan-loader
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      wayland
      alsa-lib.dev  # Add this line to provide alsa.pc
    ];

    meta = with super.lib; {
      description = "Halloy IRC Client";
      homepage = "https://github.com/squidowl/halloy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}

