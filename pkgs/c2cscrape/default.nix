{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  requests,
  beautifulsoup4,
  lxml,
  feedgen,
  pytz,
  qbittorrentApi,
  pythonDotenv,
}:

buildPythonPackage rec {
  pname = "c2cscrape";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "death916";
    repo = "c2cscrape";
    rev = "85de14caf5403bf2f4c0f3e1a2c87be5e1b24c05";
    hash = "";
  };

  format = "other";

  propagatedBuildInputs = [
    requests
    beautifulsoup4
    lxml
    feedgen
    pytz
    qbittorrentApi
    pythonDotenv
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 src/c2cscrape.py $out/bin/c2cscrape
    runHook postInstall
  '';
}
