final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.13.0";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "09bag7ki8mds79j6k2z3dbscm7q8i0dkkcfv85dcqcim9i1ky49p";
    };
  });
}
