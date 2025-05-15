# ~/Documents/nix-config/pkgs/tmuxai/default.nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, glibc
# We don't need to list tmux here because the --version flag should avoid calling it.
# If the program *insisted* on tmux even for --version, we'd need to wrap it
}:

stdenv.mkDerivation rec {
  pname = "tmuxai";
  version = "1.0.3";

  srcFilename = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
                  "tmuxai_Linux_amd64.tar.gz"
                else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
                  "tmuxai_Linux_arm64.tar.gz"
                else throw "Unsupported platform for tmuxai precompiled binary: ${stdenv.hostPlatform.system}";

  # Use the SRI formatted hashes
  srcHash = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
              "sha256-kWs5Cig9QV+dMD/XBcwWJALtBx1hbb52IOpoO0nCik4=" # Your provided correct SRI hash
            else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
              "sha256-WHcM8fmbrfBjXn+a0F+Md3lJVfSApSjpPoBq80VRUs=" # SRI for Linux arm64 (example)
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
  dontCheck = true;
  doCheck = false;

  installCheckPhase = ''
    runHook preInstallCheck
    echo "--- Starting installCheckPhase ---"
    export HOME=$(mktemp -d) # For logger, though --version should exit before full init
    echo "Set temporary HOME to $HOME for install check."

    # Use --version flag which should exit before main tmux-dependent logic
    echo "Attempting to run: $out/bin/tmuxai --version"
    VERSION_OUTPUT=$($out/bin/tmuxai --version 2>&1) # <--- CHANGED to --version
    EXIT_CODE=$?
    echo "EXIT_CODE of 'tmuxai --version': $EXIT_CODE"
    echo "OUTPUT of 'tmuxai --version':"
    echo "$VERSION_OUTPUT"
    echo "--- End of 'tmuxai --version' output ---"

    if [ "$EXIT_CODE" -ne 0 ]; then
      echo "Error: 'tmuxai --version' exited with code $EXIT_CODE."
      exit 1
    fi

    # The output of `tmuxai --version` is:
    # tmuxai version: vX.Y.Z
    # commit: <hash>
    # build date: <date>
    # So we grep for the first line.
    echo "$VERSION_OUTPUT" | grep "tmuxai version: v${version}"
    if [ $? -ne 0 ]; then
      echo "Error: Version string 'tmuxai version: v${version}' not found in output."
      exit 1
    fi

    echo "Install check passed."
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
