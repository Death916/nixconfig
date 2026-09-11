# pkgs/screenpipe/default.nix
{ lib
, stdenv
, makeWrapper
, dbus
, openssl
, oniguruma
, libgbm
, wayland
, libxcb
, pulseaudio
}:

let
  # The real binary is compiled by cargo inside the project's devenv shell, so it
  # carries no usable RPATH of its own — only the shell's store paths, which have
  # NO GC root. systemd runs it with a clean environment, so the first
  # `nix-collect-garbage` / `nh` cleanup that drops one of those paths kills the
  # service with:
  #   error while loading shared libraries: libdbus-1.so.3: cannot open ...
  #   Main process exited, code=exited, status=127
  # (observed 2026-09-09 → 2026-09-11: 8765 failed restarts).
  #
  # This wrapper IS referenced by the systemd unit, hence part of the system
  # closure, so naming the libraries here roots them and keeps them alive.
  # glibc / libstdc++ are listed too, because LD_LIBRARY_PATH is searched before
  # the binary's baked RUNPATH style fallbacks.
  #
  # If the binary ever gains new DT_NEEDED libraries, add them here — the
  # attributes below were checked against the binary's actual ldd output.
  runtimeLibs = map (p: "${lib.getLib p}/lib") [
    dbus            # libdbus-1.so.3
    openssl         # libssl.so.3, libcrypto.so.3
    oniguruma       # libonig.so.5
    libgbm          # libgbm.so.1
    wayland         # libwayland-client.so.0
    libxcb          # libxcb.so.1
    pulseaudio      # libpulse.so.0, libpulse-simple.so.0
    stdenv.cc.cc    # libstdc++.so.6, libgcc_s.so.1
    stdenv.cc.libc  # libc.so.6, libm.so.6
  ];
in
stdenv.mkDerivation {
  pname = "screenpipe";
  version = "local-npu-ocr-wrapper";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    makeWrapper \
      /home/death916/Documents/code/vibed/screenpipe/target/release/screenpipe \
      $out/bin/screenpipe \
      --prefix LD_LIBRARY_PATH : "${lib.concatStringsSep ":" runtimeLibs}"
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
