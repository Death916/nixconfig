# pkgs/screenpipe/default.nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, glibc
, alsa-lib
, openssl
, dbus
, libpulseaudio
, libgbm
, openblas
, wayland
, xorg
, xz
}:

stdenv.mkDerivation rec {
  pname = "screenpipe";
  version = "0.4.19";

  src = fetchurl {
    url = "https://registry.npmjs.org/@screenpipe/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-ci+NEQnpfxo1MAnFaQfwl/oJZAEDwjIMnG8aPGcBnYA=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glibc
    alsa-lib
    openssl
    dbus
    libpulseaudio
    libgbm
    openblas
    wayland
    xorg.libxcb
    xz
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    # The npm package contains the binary in package/bin/screenpipe
    cp package/bin/screenpipe $out/bin/screenpipe
    chmod +x $out/bin/screenpipe
    runHook postInstall
  '';

  meta = with lib; {
    description = "24/7 local screen and audio capture for AI context";
    homepage = "https://screenpi.pe";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ "death916" ];
  };
}
