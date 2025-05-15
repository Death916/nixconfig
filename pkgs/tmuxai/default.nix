# ~/Documents/nix-config/pkgs/tmuxai/default.nix
{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
, cacert # Provided by pkgs.callPackage from pkgs.cacert
}:

buildGoModule rec {
  pname = "tmuxai";
  version = "1.0.3"; # Current release

  src = fetchFromGitHub {
    owner = "alvinunreal";
    repo = "tmuxai";
    rev = "46754690d4348a21c35ac3cc51c0b9f811597cf5"; # Specific commit for v1.0.3
    # IMPORTANT: You MUST verify/correct this hash.
    # The one from your previous message was: "sha256-V8ShkIJLHU6IsqNqrr2Ty1DmhAkQDF3XXXb2bBHCviw="
    # If "XXX" is part of the hash, it's a placeholder.
    # Get the correct hash by running in your terminal:
    # nix-prefetch-github alvinunreal tmuxai --rev 46754690d4348a21c35ac3cc51c0b9f811597cf5
    # Then copy the 'hash' field from the output here.
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # <-- REPLACE THIS WITH CORRECT SRC HASH
  };

  # This will be filled in after the first failed build attempt.
  # For now, use an empty string to trigger buildGoModule to tell you the correct hash.
  vendorHash = ""; # <-- KEEP AS "" INITIALLY

  ldflags = let
    commitRevDate = src.revDate or "19700101"; # YYYYMMDD from fetchFromGitHub
    formattedDate = lib.strings.substring 0 4 commitRevDate
      + "-" + lib.strings.substring 4 2 commitRevDate
      + "-" + lib.strings.substring 6 2 commitRevDate; # YYYY-MM-DD
    actualShortRev = lib.strings.substring 0 7 src.rev; # First 7 chars of the full rev
  in [
    "-s -w"
    "-X github.com/alvinunreal/tmuxai/internal.Version=v${version}"
    "-X github.com/alvinunreal/tmuxai/internal.Commit=${actualShortRev}"
    "-X github.com/alvinunreal/tmuxai/internal.Date=${formattedDate}"
  ];

  # buildGoModule automatically sets CGO_ENABLED=0 if no Cgo is detected.
  # cacert is needed for HTTPS calls made by the Go program.
  nativeBuildInputs = [ cacert ];

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
    maintainers = with maintainers; [ "death916" ]; # Your GitHub username
    platforms = platforms.unix; # Linux and macOS
  };
}
