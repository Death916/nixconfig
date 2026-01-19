{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  requests,
  beautifulsoup4,
  lxml,
  feedgen,
  pytz,
}:

buildPythonPackage rec {
  pname = "c2cscrape";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "death916";
    repo = "c2cscrape";
    rev = "872686e9d55789986f685503695a3622aafda7e6";
    # hash = "sha256-oVuLGHds2zT/QzlFUaBzS73hwF28Wm03XwrOQbKrgdo=";
  };

  format = "other";

  propagatedBuildInputs = [
    requests
    beautifulsoup4
    lxml
    feedgen
    pytz
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 src/c2cscrape.py $out/bin/c2cscrape
    runHook postInstall
  '';
}
