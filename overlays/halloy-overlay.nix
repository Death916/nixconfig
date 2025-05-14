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

    # Enable unstable features
    RUSTC_BOOTSTRAP = 1;
    
    # Use specific nightly version that supports edition2024
    nativeBuildInputs = with super; [ 
      pkg-config 
      (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
        extensions = [ "rust-src" ];
      }))
    ];
    
    # Comprehensive patch for all dependencies
    postPatch = ''
      # Add cargo-features to main Cargo.toml
      sed -i '1i cargo-features = ["edition2024"]' Cargo.toml
      
      # Patch all dependency Cargo.toml files
      find . -name Cargo.toml -exec sed -i '1i cargo-features = ["edition2024"]' {} \;
      
      # Configure Cargo to allow unstable features
      mkdir -p .cargo
      cat > .cargo/config.toml << EOF
      [unstable]
      edition2024 = true
      [build]
      rustflags = ["-Zallow-features=edition2024"]
      EOF
    '';
    
    # Explicitly allow edition2024 features
    preBuild = ''
      export RUSTFLAGS="-Zallow-features=edition2024"
    '';

    cargoLock = {
      lockFile = super.fetchurl {
        url = "https://raw.githubusercontent.com/squidowl/halloy/${version}/Cargo.lock";
        sha256 = "sha256-s5e8T+ODhiK/fFH4lIs7SnIZX0unZPqsDIct5cntG8E=";
      };
      
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "dpi-0.1.1" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Temporary placeholder
      };
    };
    
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

