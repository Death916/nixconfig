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
    rev = "659312a0bb4bca4ce5f47a639d6430d1053b15a0";
    hash = "sha256-baGAEozqLw/dTZ7vOcP/JcXFNyNYWO0kYJp9jspoWcE=";
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
