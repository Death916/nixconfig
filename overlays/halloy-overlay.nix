self: super: {
  halloy = super.callPackage ({ rustPlatform, fetchFromGitHub }:
    rustPlatform.buildRustPackage rec {
      pname = "halloy";
      version = "2025.5";
      
      src = fetchFromGitHub {
        owner = "squidowl";
        repo = pname;
        rev = version;
        sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk="; # Keep this for now
      };

      cargoHash = ""; # Let Nix calculate this

      # Add required build inputs based on original error logs
      nativeBuildInputs = with super; [ pkg-config ];
      
      buildInputs = with super; [
        libxkbcommon
        openssl
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        wayland
      ];
    }) {};
}

