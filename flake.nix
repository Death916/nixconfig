# ~/Documents/nix-config/flake.nix
{
  description = "NixOS configurations for laptop and homelab server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # Added for Home Assistant

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
    flox.url = "github:flox/flox";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nixos-cosmic, rust-overlay, flox,  ... }:
    let
      system = "x86_64-linux";
      hmLib = home-manager.lib;

      # pkgs for the 'nixos' (laptop) configuration
      pkgsForLaptop = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
          (import ./overlays/halloy-overlay.nix) # Assuming this overlay is general
        ];
        config = { # Global config for laptop pkgs
          allowUnfree = true; # Example, add if needed
        };
      };

      # pkgs for the 'homelab' configuration (main system pkgs)
      pkgsForHomelab = import nixpkgs { # Using the stable nixpkgs for homelab base
        inherit system;
        overlays = [
          rust-overlay.overlays.default
          (import ./overlays/halloy-overlay.nix) # Assuming this overlay is general
        ];
        config = { # Global config for homelab pkgs
          allowUnfree = true; # Example, add if needed
        };
      };

      # Unstable pkgs specifically for Home Assistant on homelab
      pkgsUnstableForHA = import nixpkgs-unstable {
        inherit system;
        config = { # Global config for unstable pkgs
          allowUnfree = true; # Example
          # If HA from unstable needs OpenSSL 1.1
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
      };

    in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; }; # pkgs will be set via module below
        modules = [
          {
            nixpkgs.pkgs = pkgsForLaptop; # Use the pkgs definition with overlays for 'nixos'
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
            home-manager.extraSpecialArgs = { inherit hmLib; };
            home-manager.users.death916 = {
              imports = [ ./home-manager/home.nix ];
            };
          }
        ];
      };

      homelab = nixpkgs.lib.nixosSystem {
        inherit system;
        # Pass the unstable pkgs set for HA to the homelab configuration
        specialArgs = { inherit inputs system; unstablePkgsHA = pkgsUnstableForHA; };
        modules = [
          { nixpkgs.pkgs = pkgsForHomelab; } # Use the base pkgs definition for 'homelab'
          # Import the unstable Home Assistant module
         
          ./nixos/homelab.nix # Your main homelab config
          ./nixos/hardware-homelab.nix
          ./modules/home-assistant.nix # Your HA configuration module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit hmLib; };
            home-manager.users.death916 = {
              imports = [ ./home-manager/death916-homelab.nix ];
            };
          }
        ];
      };
    };
  };
}
