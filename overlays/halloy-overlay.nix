self: super: {
  # First create a patched version of cryoglyph
  cryoglyph = super.rustPlatform.buildRustPackage rec {
    pname = "cryoglyph";
    version = "0.1.0";
    
    src = super.fetchFromGitHub {
      owner = "iced-rs";
      repo = "cryoglyph";
      rev = "a456d1c17bbcf33afcca41d9e5e299f9f1193819"; # Get this from Halloy's Cargo.lock
      sha256 = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
    };

    RUSTC_BOOTSTRAP = 1;
    
    postPatch = ''
      sed -i '1i cargo-features = ["edition2024"]' Cargo.toml
    '';

    cargoHash = "sha256-0000000000000000000000000000000000000000000000000000"; # Let Nix fill this
  };

  # Now build Halloy with the patched cryoglyph
  halloy = super.rustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };

    RUSTC_BOOTSTRAP = 1;
    
    nativeBuildInputs = with super; [ 
      pkg-config 
      (rust-bin.nightly."2025-05-14".default.override {
        extensions = [ "rust-src" ];
      })
    ];

    postPatch = ''
      sed -i '1i cargo-features = ["edition2024"]' Cargo.toml
      sed -i 's|^cryoglyph = .*|cryoglyph = { path = "${self.cryoglyph.src}" }|' Cargo.toml
    '';

    cargoLock = {
      lockFile = super.fetchurl {
        url = "https://raw.githubusercontent.com/squidowl/halloy/${version}/Cargo.lock";
        sha256 = "sha256-s5e8T+ODhiK/fFH4lIs7SnIZX0unZPqsDIct5cntG8E=";
      };
      
      outputHashes = {
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "cryoglyph-0.1.0" = "";
         "dpi-0.1.1" = "";
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

