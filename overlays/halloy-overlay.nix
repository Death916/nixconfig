self: super:
let
  nightlyRustPlatform = super.makeRustPlatform {
    cargo = super.rust-bin.nightly.latest.default;
    rustc = super.rust-bin.nightly.latest.default;
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
    
    # Add doc_cfg to the allowed features
    RUSTFLAGS = "-Z allow-features=edition2024,doc_cfg";

    postPatch = ''
      # Add cargo-features for both edition2024 and doc_cfg
      if ! grep -q 'cargo-features = \["edition2024"\]' Cargo.toml; then
        sed -i '1i cargo-features = ["edition2024", "doc_cfg"]' Cargo.toml
      fi
      
      # Patch async_executors to enable doc_cfg feature
      find . -path "*async_executors*" -name "lib.rs" -exec sed -i '1i #![feature(doc_cfg)]' {} \;
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
    ];

    meta = with super.lib; {
      description = "Halloy IRC Client";
      homepage = "https://github.com/squidowl/halloy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}

