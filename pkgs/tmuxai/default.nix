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
              "sha256-916b390a283d415f9d303fd705cc162402ed071d616dbe7620ea683b49c28a4e"
            else if stdenv.isLinux && stdenv.hostPlatform.isAarch64 then
              "sha256-58770cf1f98badf0635e7f9ad05fbe31dde52557d20294a3a4fa01abcd1554eb"
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
    platforms = platforms.linux ++ platforms.darwin;
    # Correct way to specify provenance for a binary fetched with fetchurl
    sourceProvenance = [ src ]; # <--- CORRECTED
    # If you wanted to be more explicit with the type (less common for simple fetchurl binaries):
    # sourceProvenance = [ (lib.sourceTypes.binaryNativeCode // { inherit (src) urls meta; }) ];
  };
}
