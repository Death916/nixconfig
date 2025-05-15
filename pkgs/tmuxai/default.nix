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

  # These MUST be the SRI formatted hashes obtained from nix-prefetch-url
  srcHash = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
              "sha256-kWs5Cig9QV+dMD/XBcwWJALtBx1hbb52IOpoO0nCik4=" # SRI for Linux amd64
            else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
              "sha256-WHcM8fmbrfBjXn+a0F+Md3lJVfSApSjpPoBq80VRUs=" # SRI for Linux arm64
            else throw "Unsupported platform for tmuxai precompiled binary hash: ${stdenv.hostPlatform.system}";

  srcFetching = fetchurl {
    url = "https://github.com/alvinunreal/tmuxai/releases/download/v${version}/${srcFilename}";
    hash = srcHash;
  };

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
  dontCheck = true; # No Go tests to run on a pre-compiled binary
  doCheck = false;   # No Go tests to run on a pre-compiled binary

  # Test phase: check if the binary runs and prints version
  installCheckPhase = ''
    runHook preInstallCheck
    echo "Checking installed tmuxai version..."
    # Create a temporary, writable HOME directory for the check phase
    export HOME=$(mktemp -d)
    echo "Set temporary HOME to $HOME for install check"
    $out/bin/tmuxai version | grep "tmuxai version: v${version}"
    if [ $? -ne 0 ]; then
      echo "Version check failed!"
      $out/bin/tmuxai version # Print actual output for debugging
      exit 1
    fi
    echo "Version check passed."
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
    sourceProvenance = [
      (sourceTypes.binaryNativeCode // {
        urls = srcFetching.urls or null;
        hash = srcFetching.outputHash;
        name = srcFetching.name;
      })
    ];
  };
}
