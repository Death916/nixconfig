final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.12.0";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "0kijpb1zym2whipvvf007z6rv8kk3srfjyv8gjgw55rp3xzg1154";
    };
  });
}
