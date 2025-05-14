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

    # Enable unstable features
    RUSTC_BOOTSTRAP = 1;
    
    # Allow both edition2024 and doc_cfg features
    RUSTFLAGS = "-Z allow-features=edition2024,doc_cfg";

    # Patch Cargo.toml and source files
    postPatch = ''
      # Add cargo-features only if not present
      find . -name Cargo.toml -exec sh -c '
        if ! grep -q "cargo-features" {}; then
          sed -i "1i cargo-features = [\"edition2024\"]" {}
        fi
      ' \;
      
      # Add #![feature(doc_cfg)] to async_executors source
      mkdir -p .cargo
      echo '[build]' > .cargo/config.toml
      echo 'rustflags = ["-Z", "allow-features=edition2024,doc_cfg"]' >> .cargo/config.toml
      
      # Try to find and patch async_executors
      find . -path "*async_executors*" -name "lib.rs" -exec sed -i '1i #![feature(doc_cfg)]' {} \;
    '';

    # Dependency hashes
    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";

