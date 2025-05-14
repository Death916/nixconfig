self: super: {
  halloy = super.halloy.overrideAttrs (oldAttrs: {
    version = "2025.5";
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = "halloy";
      rev = "2025.5";
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk="; # ← Replace after build
    };
    cargoHash = ""; # ← Let Nix calculate this
  });
}

