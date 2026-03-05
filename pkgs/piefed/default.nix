{ lib
, buildPythonPackage
, fetchFromGitea
, fetchPypi
, tesseract
, tatsu
, urllib3
, flask
, python-dotenv
, flask-wtf
, flask-sqlalchemy
, flask-migrate
, flask-login
, flask-limiter
, email-validator
, flask-mail
, flask-babel
, flask-bcrypt
, psycopg2
, httpx
, pyjwt
, sqlalchemy-utils
, cryptography
, arrow
, pyld
, boto3
, markdown2
, beautifulsoup4
, flask-caching
, pillow
, pillow-heif
, feedgen
, celery
, redis
, werkzeug
, pytesseract
, sentry-sdk
, python-slugify
, furl
, ua-parser
, captcha
, pytest
, stripe
, authlib
, webauthn
, ldap3
, sqlalchemy
, orjson
, marshmallow
, flask-smorest
, ics
, dateparser
, uvicorn
, asgiref
, pygments
, fastapi
, sqlakeyset
, rich
, validators
, wtforms
}:

let
  sqlalchemy-searchable = buildPythonPackage rec {
    pname = "sqlalchemy-searchable";
    version = "1.4.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-0000000000000000000000000000000000000000000=";
    };
    propagatedBuildInputs = [
      sqlalchemy
      sqlalchemy-utils
      validators
    ];
    doCheck = false;
  };

  bootstrap-flask = buildPythonPackage rec {
    pname = "bootstrap-flask";
    version = "2.5.0";
    src = fetchPypi {
      pname = "Bootstrap-Flask";
      inherit version;
      hash = "sha256-0000000000000000000000000000000000000000000=";
    };
    propagatedBuildInputs = [
      flask
      wtforms
    ];
    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "piefed";
  version = "1.6.8";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rimu";
    repo = "pyfedi";
    rev = "v${version}";
    hash = "sha256-0000000000000000000000000000000000000000000=";
  };

  format = "other";

  propagatedBuildInputs = [
    tatsu
    urllib3
    flask
    python-dotenv
    flask-wtf
    flask-sqlalchemy
    flask-migrate
    flask-login
    flask-limiter
    email-validator
    flask-mail
    flask-babel
    flask-bcrypt
    psycopg2
    httpx
    pyjwt
    sqlalchemy-utils
    cryptography
    arrow
    pyld
    boto3
    markdown2
    beautifulsoup4
    flask-caching
    pillow
    pillow-heif
    feedgen
    celery
    redis
    werkzeug
    pytesseract
    sentry-sdk
    python-slugify
    furl
    ua-parser
    captcha
    pytest
    stripe
    authlib
    webauthn
    ldap3
    sqlalchemy
    orjson
    marshmallow
    flask-smorest
    ics
    dateparser
    uvicorn
    asgiref
    pygments
    fastapi
    sqlakeyset
    rich
    sqlalchemy-searchable
    bootstrap-flask
  ];

  buildInputs = [ tesseract ];

  installPhase = ''
    mkdir -p $out/opt/piefed
    cp -rv . $out/opt/piefed
  '';
}
