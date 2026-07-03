# pkgs/screenpipe/default.nix
{ lib
, stdenv
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
  version = "local-npu-ocr";

  # Point directly to the locally compiled NPU-patched release binary
  src = /home/death916/Documents/code/vibed/screenpipe/target/release/screenpipe;

  dontUnpack = true;

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
    cp $src $out/bin/screenpipe
    chmod +x $out/bin/screenpipe
    runHook postInstall
  '';

  meta = with lib; {
    description = "24/7 local screen and audio capture for AI context (Local NPU OCR Patched)";
    homepage = "https://screenpi.pe";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ "death916" ];
  };
}
