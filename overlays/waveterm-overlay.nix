final: prev: {
  waveterm = prev.waveterm.overrideAttrs (oldAttrs: rec {
    version = "0.14.0";

    src = prev.fetchurl {
      url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/waveterm-linux-amd64-${version}.deb";
      sha256 = "sha256-YTPNs69Ss+fgk0n7sFbNMafueDrSNnri2Ndy3TyeLq4=";
    };
  });
}
