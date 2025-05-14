self: super: {
  halloy = super.stdenv.mkDerivation rec {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };
    
    # Explicitly set the sourceRoot
    sourceRoot = "source";
    
    # Use Rust 1.85 or newer which has stable edition2024 support
    nativeBuildInputs = with super; [
      pkg-config
      (rust-bin.stable."1.85.0".default)
    ];
    
    # No need to patch for edition2024 features as they're stable in 1.85
    postPatch = ''
      # Update Cargo.toml to use edition 2024
      sed -i 's/edition = "2021"/edition = "2024"/' Cargo.toml
      
      # Find and update edition in all subcrates
      find . -name Cargo.toml -exec sed -i 's/edition = "2021"/edition = "2024"/' {} \;
    '';
    
    # Build with cargo
    buildPhase = ''
      # Make sure we're in the right directory
      echo "Current directory: $(pwd)"
      ls -la
      
      # Build the project
      cargo build --release
    '';
    
    # Install the binary
    installPhase = ''
      mkdir -p $out/bin
      cp target/release/halloy $out/bin/
    '';
    
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

