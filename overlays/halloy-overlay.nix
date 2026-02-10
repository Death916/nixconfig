self: super:
/*
  let
    nightlyRustPlatform = super.makeRustPlatform {
      cargo = super.rust-bin.nightly."2025-07-28".default;
      rustc = super.rust-bin.nightly."2025-07-28".default;
    };
  in
*/
{
  # halloy = nightlyRustPlatform.buildRustPackage rec {
  halloy = super.rustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2026.2";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-qQ6hNpOqI3yC26KqYYq42KjJw/bMzaXACpGyIXE2axo=";
    };

    # RUSTC_BOOTSTRAP = 1;
    # RUSTFLAGS = "-Z allow-features=let_chains";

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-iBpeC4g/C2rkMWxoOahPJ4aECqsE2rnxDeFEmuBPj3k=";
        "iced-0.15.0-dev" = "sha256-QEBGpD+L5TFLazz9aY45pyq6J4dDc9LUmX81ueRWshk=";
        "dpi-0.1.1" = "sha256-pQn1lCFSJMkjUfHoggEzMHnm5k+Chnzi5JEDjahnjUA=";
        "cosmic-text-0.15.0" = "sha256-IcaVn8r6qGWhgNnZchRHIgcMSNYE61Bfc3n29X9N7xY=";
      };
    };

    nativeBuildInputs = with super; [
      pkg-config
      makeWrapper
    ];

    buildInputs = with super; [
      libxkbcommon
      openssl
      vulkan-loader
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libxcb
      wayland
      alsa-lib.dev
    ];

    postInstall = ''
      wrapProgram $out/bin/halloy \
        --prefix LD_LIBRARY_PATH : ${
          super.lib.makeLibraryPath [
            super.wayland
            super.libxkbcommon
            super.vulkan-loader
            super.alsa-lib
            super.openssl
            super.xorg.libxcb
          ]
        }

      mkdir -p $out/share/applications
      cat > $out/share/applications/halloy.desktop << EOF
      [Desktop Entry]
      Type=Application
      Name=Halloy IRC Client
      Exec=$out/bin/halloy
      Comment=A modern IRC client built with Rust
      Categories=Network;Chat;
      Terminal=false
      EOF
    '';

    meta = with super.lib; {
      description = "Halloy IRC Client";
      homepage = "https://github.com/squidowl/halloy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}
