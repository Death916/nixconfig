self: super: {
  halloy = super.halloy.overrideAttrs (oldAttrs: rec {
    version = "2025.5";
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = "halloy";
      rev = "2025.5";
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk="; # <--- Replace after first build
    };
    # If the build fails due to Cargo.lock, you may also need to override cargoSha256:
    cargoSha256 = "0000000000000000000000000000000000000000000000000000"; # Replace if needed
  });
}
