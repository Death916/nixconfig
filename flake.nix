# ~/Documents/nix-config/flake.nix
{
  description = "NixOS configurations for laptop and homelab server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-cosmic, rust-overlay, ... }:
    let
      system = "x86_64-linux";

      # Pass home-manager.lib in commonSpecialArgs
      commonSpecialArgs = {
        inherit inputs system;
        hmLib = home-manager.lib; # <--- ADD THIS
      };

      pkgsWithOverlays = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
          (import ./overlays/halloy-overlay.nix)
        ];
      };
    in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs; # This now includes hmLib
        modules = [
          {
            nixpkgs.pkgs = pkgsWithOverlays;
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          ./nixos/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.death916 = {
              imports = [ ./home-manager/home.nix ];
              # Pass hmLib to the user's Home Manager config if needed there directly,
              # or rely on it being in `specialArgs` for modules imported by home.nix.
              # For modules imported by Home Manager itself, it passes its own specialArgs.
              # The `config` argument in home.nix should already have `config.lib` correctly set by HM.
              # However, we are passing `hmLib` via `specialArgs` to the NixOS module system,
              # which then makes it available to all modules including home.nix.
            };
            # If you wanted to pass it specifically to HM modules for that user:
            # home-manager.extraSpecialArgs = { inherit (commonSpecialArgs) hmLib; };
            # But it should be available via the top-level specialArgs passed to nixosSystem.
          }
        ];
      };

      # Homelab config also needs specialArgs if its home.nix needs hmLib
      homelab = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs; # Includes hmLib
        modules = [
          { nixpkgs.pkgs = pkgsWithOverlays; }
          ./nixos/homelab.nix
          ./nixos/hardware-homelab.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.death916 = {
              imports = [ ./home-manager/death916-homelab.nix ];
            };
          }
        ];
      };
    };
  };
}
