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
  version = "1.0.3"; # Current release

  # For Linux x86_64 (amd64)
  srcFilename = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
                  "tmuxai_Linux_amd64.tar.gz"
                else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
                  "tmuxai_Linux_arm64.tar.gz"
                # Add more platform conditions if needed, e.g., for Darwin
                # else if stdenv.isDarwin && stdenv.hostPlatform.isx86_64 then
                #   "tmuxai_Darwin_amd64.tar.gz"
                # else if stdenv.isDarwin && stdenv.hostPlatform.isAarch64 then
                #   "tmuxai_Darwin_arm64.tar.gz"
                else throw "Unsupported platform for tmuxai precompiled binary: ${stdenv.hostPlatform.system}";

  srcHash = if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
              "sha256-916b390a283d415f9d303fd705cc162402ed071d616dbe7620ea683b49c28a4e" # From your tmuxsha256.txt for Linux amd64
            else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
              "sha256-58770cf1f98badf0635e7f9ad05fbe31dde52557d20294a3a4fa01abcd1554eb" # From your tmuxsha256.txt for Linux arm64
            # else if stdenv.isDarwin && stdenv.hostPlatform.isx86_64 then
            #   "sha256-41e880247972f86874aef4e60a77db93e2c2b47d857f1088b856af8e98f20d9d" # Darwin amd64
            # else if stdenv.isDarwin && stdenv.hostPlatform.isAarch64 then
            #   "sha256-ff40f1c4605933507c8f65e3a694756740cc5b65b264457f9f454f1d9f00f8d9" # Darwin arm64
            else throw "Unsupported platform for tmuxai precompiled binary hash: ${stdenv.hostPlatform.system}";

  src = fetchurl {
    url = "https://github.com/alvinunreal/tmuxai/releases/download/v${version}/${srcFilename}";
    hash = srcHash;
  };

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
    platforms = platforms.linux ++ platforms.darwin; # Reflects available binaries
    sourceProvenance = [ lib.sourceTypes.binaryTarball ]; # Corrected sourceProvenance
  };
}
