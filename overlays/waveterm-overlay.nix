final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.13.0";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "vEQp+LoFRyY6pPUdbYC8HGOnE8MdFz4emUkqAOSVArA=";
    };
  });
}
