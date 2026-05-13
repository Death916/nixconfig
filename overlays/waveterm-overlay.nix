final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.14.5";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "sha256-aRrOVi5mog2XJ7i+6vmP5kpEXfZVI7sf0R7TD1b9E3s=";
    };
  });
}
