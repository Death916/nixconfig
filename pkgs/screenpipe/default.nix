# pkgs/screenpipe/default.nix
{ lib
, stdenv
}:

stdenv.mkDerivation {
  pname = "screenpipe";
  version = "local-npu-ocr-wrapper";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cat <<'EOF' > $out/bin/screenpipe
#!/bin/sh
exec /home/death916/Documents/code/vibed/screenpipe/target/release/screenpipe "$@"
EOF
    chmod +x $out/bin/screenpipe
    runHook postInstall
  '';

  meta = with lib; {
    description = "24/7 local screen and audio capture (Wrapper pointing to local compiled NPU binary)";
    homepage = "https://screenpi.pe";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ "death916" ];
  };
}
