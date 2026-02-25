self: super:
let
  nightlyRustPlatform = super.makeRustPlatform {
    cargo = super.rust-bin.stable.latest.default;
    rustc = super.rust-bin.stable.latest.default;
  };
in
{
  halloy = nightlyRustPlatform.buildRustPackage rec {
    pname = "halloy";
    version = "2026.3";

    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = pname;
      rev = version;
      sha256 = "sha256-lIPLJSiQmDBpFgKALjT/hSdiY5YfQkIZo8LdrxPHGqs=";
    };

    # RUSTC_BOOTSTRAP = 1;
    # RUSTFLAGS = "-Z allow-features=let_chains";

    cargoHash = "sha256-g9Q2YCjgC5MBX/Tv/dvRuHIxo7qq5J7hjsw3YeTn0jI=";

    nativeBuildInputs = with super; [
      pkg-config
      makeWrapper
    ];

    buildInputs = with super; [
      libxkbcommon
      openssl
      vulkan-loader
      libx11
      libxcursor
      libxi
      libxrandr
      libxcb
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
            super.libxcb
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
