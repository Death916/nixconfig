self: super:
let
  nightlyRustPlatform = super.makeRustPlatform {
    cargo = super.rust-bin.nightly."2025-07-28".default;
    rustc = super.rust-bin.nightly."2025-07-28".default;
  };
in
{
  halloy = nightlyRustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2025.11";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-5cYTHb3KK5EiPv5P8GZOoQwSSIe0FO+qBnpvLZtuByI=";
    };

    RUSTC_BOOTSTRAP = 1;
    RUSTFLAGS = "-Z allow-features=let_chains";

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      outputHashes = {
        "cryoglyph-0.1.0" = "sha256-Jc+rhzd5BIT7aYBtIfsBFFKkGChdEYhDHdYGiv4KE+c=";
        "iced-0.14.0-dev" = "sha256-OBay5XHpn0pUxOv8/QkgB8Nv9zbiXWeaHIEzJ/YkADo=";
        "dpi-0.1.1" = "sha256-pQn1lCFSJMkjUfHoggEzMHnm5k+Chnzi5JEDjahnjUA=";
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
