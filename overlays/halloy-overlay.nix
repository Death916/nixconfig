self: super:
let
  # Pin to a specific nightly that supports edition2024
  rustNightly = super.rust-bin.nightly."2025-05-14".default.override {
    extensions = [ "rust-src" ];
  };
in {
  halloy = super.rustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };

    # Force use of pinned nightly toolchain
    cargo = rustNightly;
    rustc = rustNightly;
    
    # Required for edition2024 features
    RUSTC_BOOTSTRAP = 1;

    # Patch all Cargo.toml files recursively
    postPatch = ''
      find . -name Cargo.toml -exec sed -i '1i cargo-features = ["edition2024"]' {} \;
    '';

    # Use crane's vendor approach for better dependency handling
    cargoDeps = super.rustPlatform.importCargoLock {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "dpi-0.1.1" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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
  };
}

