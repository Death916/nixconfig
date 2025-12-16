final: prev: {
  meilisearch = prev.meilisearch.overrideAttrs (old: {
    pname = "meilisearch-bin";
    version = "1.13.3";
    src = prev.fetchurl {
      url = "https://github.com/meilisearch/meilisearch/releases/download/v1.13.3/meilisearch-linux-amd64";
      sha256 = "077ab23bb5ab9bdd1765e9f1641eec8eefd793d3d51f0fd3e8357fb0ad43770c";
    };
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      install -Dm755 $src $out/bin/meilisearch
    '';
    # Fix dynamic linking issues for the binary
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.autoPatchelfHook ];
  });
}
