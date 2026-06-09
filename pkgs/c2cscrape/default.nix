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
    rev = "fb7f423aa737817b3516d91f7c5dedd777556040";
    hash = "sha256-BkTwJeX3KiaQS5WBg5qEKgvkP9V7qLiR7iQoaIciDVc=";
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
