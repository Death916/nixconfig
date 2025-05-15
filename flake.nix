# ~/Documents/nix-config/flake.nix
{
  description = "NixOS configurations for laptop and homelab server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; # Or nixos-unstable for more recent packages

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11"; # Matches nixpkgs release branch
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-cosmic, rust-overlay, ... }:
    let
      system = "x86_64-linux"; # Specify your system architecture

      commonSpecialArgs = {
        inherit inputs system;
      };

      # Apply overlays once to create the package set to be used
      pkgsWithOverlays = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
          (import ./overlays/halloy-overlay.nix) # Ensure this path is correct
        ];
      };

    in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem { # Replace 'nixos' with your actual laptop's hostname if different
        inherit system;
        specialArgs = commonSpecialArgs;
        modules = [
          { # Module to set the global pkgs for this NixOS configuration
            nixpkgs.pkgs = pkgsWithOverlays; # This makes pkgsWithOverlays the default pkgs for this system
            nix.settings = { # COSMIC-specific Cachix settings
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          ./nixos/configuration.nix # Your existing laptop NixOS configuration

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true; # This tells HM to use the system's pkgs (which is now pkgsWithOverlays)
            home-manager.useUserPackages = true;
            # No need for home-manager.pkgs = pkgsWithOverlays; here,
            # useGlobalPkgs = true handles it by inheriting from nixpkgs.pkgs set above.
            home-manager.users.death916 = {
              imports = [ ./home-manager/home.nix ];
            };
          }
        ];
      };

      homelab = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs;
        modules = [
          { nixpkgs.pkgs = pkgsWithOverlays; } # Apply overlays to homelab too
          ./nixos/homelab.nix
          ./nixos/hardware-homelab.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # No need for home-manager.pkgs here either
            home-manager.users.death916 = {
              imports = [ ./home-manager/death916-homelab.nix ];
            };
          }
        ];
      };
    };
  };
}
