final: prev: {
  realvnc-vnc-viewer = prev.realvnc-vnc-viewer.overrideAttrs (oldAttrs: {
    src = prev.fetchurl {
      url = "https://web.archive.org/web/20251031125546/https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.15.1-Linux-x64.rpm";
      hash = "sha256-rIOP7d8qrOeMgaQRYo+GRXT1fLnPegdpONT0p5aBCxM=";
    };
  });
}
