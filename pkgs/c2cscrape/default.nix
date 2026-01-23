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
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "death916";
    repo = "c2cscrape";
    rev = "872686e9d55789986f685503695a3622aafda7e6";
    hash = "sha256-wBvX4P8j+2nz8+WimSBSPKqCuC5uD6TT52xR+6dQ+ns=";
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
