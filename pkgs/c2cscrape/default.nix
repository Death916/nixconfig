{ lib
, buildPythonPackage
, fetchFromGitHub
, requests
, beautifulsoup4
, lxml
, feedgen
, pytz
}:

buildPythonPackage rec {
  pname = "c2cscrape";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "death916";
    repo = "c2cscrape";
    rev = "b61b888b229d646859976f8fb69e59c17c8c27a4";
    hash = "sha256-oVuLGHds2zT/QzlFUaBzS73hwF28Wm03XwrOQbKrgdo=";
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
