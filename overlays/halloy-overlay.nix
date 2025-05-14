self: super:
let
  # Create wrapper scripts as before
  rustcWrapper = super.writeShellScriptBin "rustc" ''
    exec ${super.rust-bin.nightly.latest.rustc}/bin/rustc --allow-features=edition2024 "$@"
  '';
  
  cargoWrapper = super.writeShellScriptBin "cargo" ''
    export RUSTC=${rustcWrapper}/bin/rustc
    export RUSTC_BOOTSTRAP=1
    exec ${super.rust-bin.nightly.latest.cargo}/bin/cargo "$@"
  '';
in {
  halloy = super.stdenv.mkDerivation rec {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };
    
    # Don't set sourceRoot - let Nix determine it automatically
    
    # Use our custom wrappers
    nativeBuildInputs = with super; [
      pkg-config
      rustcWrapper
      cargoWrapper
      rust-bin.nightly.latest.rustc
      rust-bin.nightly.latest.cargo
    ];
    
    # Modify postUnpack to work with the actual directory structure
    postUnpack = ''
      # First check what directories we have
      ls -la
      
      # Find the actual source directory (it might not be called "source")
      sourceRoot=$(find . -type d -name "halloy*" | head -n 1)
      echo "Setting sourceRoot to $sourceRoot"
      
      # Now patch the Cargo.toml files
      cd "$sourceRoot"
      find . -name Cargo.toml -exec sed -i '1i cargo-features = ["edition2024"]' {} \;
      
      # Create .cargo/config.toml to enable edition2024
      mkdir -p .cargo
      cat > .cargo/config.toml << EOF
      [unstable]
      edition2024 = true
      EOF
    '';
    
    # Build with cargo
    buildPhase = ''
      export RUSTC_BOOTSTRAP=1
      export RUSTFLAGS="--allow-features=edition2024"
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

