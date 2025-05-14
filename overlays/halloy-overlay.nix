self: super: {
  halloy = super.halloy.overrideAttrs (oldAttrs: rec {
    version = "2025.5";
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = "halloy";
      rev = "2025.5";
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
      name = "${pname}-${version}-vendor";
      inherit src;
      outputHash = "";
    });
  });
}

