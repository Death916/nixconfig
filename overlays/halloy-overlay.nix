self: super:
let
  # Define a Rust platform that uses nightly by default for all its operations.
  # `super.rust-bin.nightly.latest.default` comes from the rust-overlay you have in your flake.nix.
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

    # RUSTC_BOOTSTRAP = 1 allows the use of -Z flags (unstable features)
    # with the nightly toolchain. This should be inherited by dependency builds.
    RUSTC_BOOTSTRAP = 1;

    # Set RUSTFLAGS globally. The nightly cargo used by nightlyRustPlatform
    # for compiling dependencies should pick this up.
    RUSTFLAGS = "-Z allow-features=edition2024";

    # The postPatch for the main halloy package.
    # This ensures halloy itself declares edition 2024.
    # Dependencies like cryoglyph are handled by the nightly cargo respecting RUSTFLAGS.
    postPatch = ''
      # Ensure Halloy's main Cargo.toml uses edition 2024 and has the cargo-features line.
      # This is mostly for the top-level crate.
      if ! grep -q 'edition = "2024"' Cargo.toml; then
        if grep -q 'edition = ' Cargo.toml; then
          sed -i 's/edition = .*/edition = "2024"/' Cargo.toml
        else
          # A simple way to add it if not present at all
          sed -i '/\[package\]/a edition = "2024"' Cargo.toml
        fi
      fi
      if ! grep -q 'cargo-features = \["edition2024"\]' Cargo.toml; then
        sed -i '1i cargo-features = ["edition2024"]' Cargo.toml
      fi
    '';

    # cargoLock manages fixed-output derivations for dependencies.
    # The nightlyRustPlatform should use its nightly cargo to build these.
    cargoLock = {
      # Assuming Cargo.lock is present in the fetched source of halloy
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-X7S9jq8wU6g1DDNEzOtP3lKWugDnpopPDBK49iWvD4o=";
        "dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-FEGk1zkXM9o+fGMoDtmi621G6pL+Yca9owJz4q2Lzks=";
        "winit-0.30.8" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
        

        # You will get an error for this placeholder.
        # Replace it with the actual hash provided in the error message.
        "dpi-0.1.1" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
      };
    };

    # System dependencies for Halloy
    nativeBuildInputs = with super; [ pkg-config ]; # Rust toolchain is handled by nightlyRustPlatform

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
      maintainers = with maintainers; [ ]; # Add your handle if you wish
      platforms = platforms.linux;
    };
  };
}

