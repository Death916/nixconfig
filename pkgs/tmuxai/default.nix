# ~/Documents/nix-config/pkgs/tmuxai/default.nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, glibc
}:

stdenv.mkDerivation rec {
  pname = "tmuxai";
  version = "1.0.3";

  srcFilename = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
                  "tmuxai_Linux_amd64.tar.gz"
                else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
                  "tmuxai_Linux_arm64.tar.gz"
                else throw "Unsupported platform for tmuxai precompiled binary: ${stdenv.hostPlatform.system}";

  srcHash = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
              "sha256-kWs5Cig9QV+dMD/XBcwWJALtBx1hbb52IOpoO0nCik4="
            else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
              "sha256-kWs5Cig9QV+dMD/XBcwWJALtBx1hbb52IOpoO0nCik4="
            else throw "Unsupported platform for tmuxai precompiled binary hash: ${stdenv.hostPlatform.system}";

  # Define `srcFetching` for clarity, to be used in `sourceProvenance`
  srcFetching = fetchurl {
    url = "https://github.com/alvinunreal/tmuxai/releases/download/v${version}/${srcFilename}";
    hash = srcHash;
  };

  # `src` attribute is still needed by mkDerivation for the actual source path
  src = srcFetching;

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glibc
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 -D tmuxai $out/bin/tmuxai
    runHook postInstall
  '';

  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  doCheck = false;

  installCheckPhase = ''
    runHook preInstallCheck
    echo "Checking installed tmuxai version..."
    $out/bin/tmuxai version | grep "tmuxai version: v${version}"
    runHook postInstallCheck
  '';
  doInstallCheck = true;

  meta = with lib; {
    description = "Your intelligent pair programmer directly within your tmux sessions";
    longDescription = ''
      TmuxAI is an intelligent terminal assistant that lives inside your tmux sessions.
      Unlike other CLI AI tools, TmuxAI observes and understands the content of your
      tmux panes, providing assistance without requiring you to change your workflow
      or interrupt your terminal sessions.
    '';
    homepage = "https://github.com/alvinunreal/tmuxai";
    license = licenses.asl20;
    maintainers = with maintainers; [ "death916" ];
    platforms = platforms.linux ++ platforms.darwin;

    # Correctly specify source provenance for a pre-compiled binary
    sourceProvenance = [
      (sourceTypes.binaryNativeCode // {
        # We need to provide the 'urls' and 'sha256' (or 'hash') attributes
        # that sourceTypes.binaryNativeCode might expect for its own validation,
        # or that check-meta might look for.
        # We can take these directly from our `srcFetching` attributes.
        urls = srcFetching.urls or null; # fetchurl provides `urls` as a list
        # The hash from fetchurl is already in the correct format.
        # `fetchurl` result has `outputHash` and `outputHashAlgo`.
        # `check-meta` often looks for `sha256` or `hash`.
        # Let's provide what `srcFetching` has.
        hash = srcFetching.outputHash; # Or just `srcFetching.hash` if that's how you defined it.
                                       # `fetchurl` sets `outputHash` and `outputHashAlgo`.
        # It might also look for `name` if not an actual derivation.
        # Let's use the `name` from `srcFetching` which is usually the filename part of the URL.
        name = srcFetching.name;
      })
    ]; # <--- CORRECTED
  };
}
