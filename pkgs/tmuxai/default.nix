# ~/Documents/nix-config/pkgs/tmuxai/default.nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
  # Add runtime dependencies of the binary if known/needed.
  # For a Go binary, it's often self-contained, but sometimes needs libc, libpthread.
  # These are usually part of stdenv.cc.cc.lib or glibc.
  # autoPatchelfHook will try to find them.
, glibc # For basic C library dependencies
# , tmux # tmux is a runtime dep, but typically installed separately by the user
}:

stdenv.mkDerivation rec {
  pname = "tmuxai";
  version = "1.0.3"; # Current release

  # Determine src based on system architecture
  # The install.sh script constructs the filename as:
  # ${PROJECT_NAME}_${os_raw}_${arch}.${archive_ext}
  # os_raw is `Linux` or `Darwin`. arch is `amd64` or `arm64`.
  # Example: tmuxai_Linux_amd64.tar.gz

  # For Linux x86_64:
  srcFilename = "${pname}_Linux_amd64.tar.gz";
  srcHash = "sha256-58770cf1f98badf0635e7f9ad05fbe31dde52557d20294a3a4fa01abcd1554eb"; # <-- TODO: GET HASH for tmuxai_Linux_amd64.tar.gz v1.0.3

  # For Linux aarch64 (if you need it):
  # srcFilename = if stdenv.hostPlatform.system == "aarch64-linux"
  #               then "${pname}_Linux_arm64.tar.gz"
  #               else "${pname}_Linux_amd64.tar.gz";
  # srcHash = if stdenv.hostPlatform.system == "aarch64-linux"
  #           then "sha256-yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy=" # <-- TODO: HASH for arm64
  #           else "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx="; # <-- TODO: HASH for amd64

  src = fetchurl {
    url = "https://github.com/alvinunreal/tmuxai/releases/download/v${version}/${srcFilename}";
    # The hash needs to be for the specific binary archive you download.
    # To get the hash:
    # 1. Go to: https://github.com/alvinunreal/tmuxai/releases/tag/v1.0.3
    # 2. Download the correct .tar.gz file (e.g., tmuxai_Linux_amd64.tar.gz)
    # 3. Run: nix-prefetch-url file:///path/to/downloaded/tmuxai_Linux_amd64.tar.gz
    #    OR directly: nix-prefetch-url https://github.com/alvinunreal/tmuxai/releases/download/v1.0.3/tmuxai_Linux_amd64.tar.gz
    # 4. Copy the sha256 hash here.
    hash = srcHash;
  };

  # autoPatchelfHook needs to know where to find the ELF files.
  # The binary is typically at the root of the tar.gz.
  sourceRoot = "."; # The binary is directly in the archive after extraction

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper # To potentially wrap the binary if needed later
  ];

  # buildInputs are dependencies the binary might need at runtime.
  # For a typical Go binary, glibc might be enough.
  # autoPatchelfHook will use these to patch the RPATH.
  buildInputs = [
    glibc
    # If tmuxai dynamically links against other specific libraries, add them here.
    # e.g., if it used libcurl directly (unlikely for Go), you'd add pkgs.curl.
    # The .goreleaser.yml sets CGO_ENABLED=0, so it should be statically linked against Go libs,
    # but will still dynamically link against system C libraries like glibc, libpthread.
  ];

  # We don't need to build anything, just install the pre-compiled binary.
  # The install.sh script does `install -m755 "$binary_path" "$target_path"`
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    # The binary is named 'tmuxai' inside the archive.
    install -m755 -D tmuxai $out/bin/tmuxai

    # If you need to wrap the binary to set environment variables (e.g., for API keys if not handled by user env)
    # or ensure tmux is found:
    # wrapProgram $out/bin/tmuxai \
    #   --prefix PATH : ${lib.makeBinPath [ tmux ]} # Example: ensure tmux is in PATH for the binary

    runHook postInstall
  '';

  # We are not building from source, so some Go-specific phases are not needed.
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true; # No tests to run on a pre-compiled binary
  doCheck = false;

  # Test phase: check if the binary runs and prints version
  # This is optional but good practice.
  # It uses the version embedded by goreleaser.
  installCheckPhase = ''
    runHook preInstallCheck
    echo "Checking installed tmuxai version..."
    $out/bin/tmuxai version | grep "tmuxai version: v${version}"
    # The goreleaser config sets internal.Version to "v{{.Version}}"
    # So we grep for "v1.0.3" for example.
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
    platforms = platforms.linux; # The binaries are provided for Linux and Darwin
    # If you need macOS, you'd add another src/hash conditional block or a separate derivation.
    sourceProvenance = [แหล่งที่มา.binaryTarball inputs.src]; # Indicate it's a binary
  };
}
