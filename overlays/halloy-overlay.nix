self: super: {
  halloy = super.rustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };
    
    # Use Rust 1.85 which has stable edition2024 support
    cargoToolchain = super.rust-bin.stable."1.85.0".default;
    
    # Don't try to fetch dependencies during build
    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "dpi-0.1.1" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
      };
    };
    
    # Update edition in all Cargo.toml files
    postPatch = ''
      find . -name Cargo.toml -exec sed -i 's/edition = "2021"/edition = "2024"/' {} \;
    '';
    
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

