# pkgs/screenpipe/default.nix
{ lib
, stdenv
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "screenpipe";
  version = "local-npu-ocr-wrapper";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper /home/death916/Documents/code/vibed/screenpipe/target/release/screenpipe $out/bin/screenpipe
  '';

  meta = with lib; {
    description = "24/7 local screen and audio capture (Wrapper pointing to local compiled NPU binary)";
    homepage = "https://screenpi.pe";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ "death916" ];
  };
}
