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
    
    # Use the nightly Rust toolchain
    nativeBuildInputs = with super; [ 
      pkg-config 
      (super.rust-bin.nightly.latest.default.override {
        extensions = [ "rust-src" ];
      })
    ];
    
    # Patch all Cargo.toml files to add cargo-features
    postPatch = ''
      # Add cargo-features to main Cargo.toml
      sed -i '1i cargo-features = ["edition2024"]' Cargo.toml
      
      # Create a patch for the dependencies
      mkdir -p .cargo
      cat > .cargo/config.toml << EOF
      [unstable]
      edition2024 = true
      EOF
    '';
    
    # Patch for cryoglyph dependency
    cargoPatches = [
      (super.writeTextFile {
        name = "add-cargo-features-patch";
        destination = "/cargo-features-patch";
        text = ''
          diff --git a/Cargo.toml b/Cargo.toml
          index 1111111..2222222 100644
          --- a/Cargo.toml
          +++ b/Cargo.toml
          @@ -0,0 +1 @@
          +cargo-features = ["edition2024"]
          
        '';
      })
    ];
    
    # Apply patch to dependencies during build
    preBuild = ''
      export RUSTFLAGS="-Z allow-features=edition2024"
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

