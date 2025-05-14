self: super: {
  halloy = super.rustPlatform.buildRustPackage {
    pname = "halloy";
    version = "2025.5";
    
    src = super.fetchFromGitHub {
      owner = "squidowl";
      repo = "halloy";
      rev = "2025.5";
      sha256 = "sha256-cG/B6oiRkyoC5fK7bLdCDQYZymfMZspWXvOkqpwHRPk=";
    };
    
    # Use cargoLock instead of cargoHash
    cargoLock = {
      lockFile = super.fetchurl {
        url = "https://raw.githubusercontent.com/squidowl/halloy/2025.5/Cargo.lock";
        sha256 = "sha256-s5e8T+ODhiK/fFH4lIs7SnIZX0unZPqsDIct5cntG8E="; # This will fail first, replace with actual hash
      };
      
      # Add hashes for git dependencies
      outputHashes = {
        # These will need to be filled in iteratively
        # "cryoglyph-0.0.0" = "";
        # "dark-light-0.0.0" = "";
        # "iced-0.0.0" = "";
        # "winit-0.0.0" = "";
      };
    };
    
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
  };
}

