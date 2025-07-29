self: super:
let
  # Use the standard stable rust platform provided by nixpkgs
  stableRustPlatform = super.rustPlatform;
in
{
  halloy = stableRustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.7";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-qBBJAW2QKwcqZRS3D/giT2EzruuGLrCne7odz2vl9is=";
    };

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-Jc+rhzd5BIT7aYBtIfsBFFKkGChdEYhDHdYGiv4KE+c=";
        #"dark-light-2.0.0" = "sha256-e826vF7iSkGUqv65TXHBUX04Kz2aaJJEW9f7JsAMaXE=";
        "iced-0.14.0-dev" = "sha256-mt9PsX3FjLFIaE8OyPxCRFeSaxrmZaiVs+QwV2oYtVc=";
        "winit-0.30.8" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
        "dpi-0.1.1" = "sha256-hlVhlQ8MmIbNFNr6BM4edKdZbe+ixnPpKm819zauFLQ=";
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
