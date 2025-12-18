final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.13.1";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "q2rdc/DpVVRDK2X9QyS8w7gkHZAQR+Wopn40Vip9CeE=";
    };
  });
}
