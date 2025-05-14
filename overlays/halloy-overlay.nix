self: super: {
  halloy = super.halloy.overrideAttrs (oldAttrs: rec {
    version = "2025.5";
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = "halloy";
      rev = "2025.5";
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk="; # Will get proper hash from error
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (super.lib.const {
      name = "${pname}-${version}-vendor";
      inherit src;
      outputHash = "0000000000000000000000000000000000000000000000000000"; # Will get proper hash from error
    });
  });
}

