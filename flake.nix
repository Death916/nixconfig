# flake.nix
{
  description = "NixOS configurations for laptop and homelab server";

  inputs = {
    # Main Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; # Or your preferred branch

    # COSMIC Desktop for laptop
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11"; # Or your preferred branch
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-cosmic, ... }:
    let
      # Common arguments to pass to all system configurations
      commonSpecialArgs = {
        inherit inputs;
      };
    in
  {
    nixosConfigurations = {
      # Laptop configuration (assuming it's named 'nixos' or your laptop's actual hostname)
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Specify your laptop's architecture
        specialArgs = commonSpecialArgs;
        modules = [
          { # COSMIC-specific Cachix settings for the laptop
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default # COSMIC Desktop Environment for laptop
          ./nixos/configuration.nix         # Your existing laptop NixOS configuration
          # Add any custom modules from ./modules for the laptop here
          # e.g., ./modules/laptop-specific.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.death916 = {
              imports = [ ./home-manager/home.nix ]; # Laptop Home Manager config for death916
            };
          }
        ];
      };

      # Homelab Server configuration
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Specify your server's architecture
        specialArgs = commonSpecialArgs;
        modules = [
          ./nixos/homelab.nix # Homelab server's main NixOS configuration
          # Add any custom modules from ./modules for the homelab server here
          # e.g., ./modules/server-common.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.death916 = {
              imports = [ ./home-manager/death916-homelab.nix ]; # Homelab Home Manager config for death916
            };
          }
        ];
      };
    };

    # If you have global overlays from ./overlays:
    # nixpkgs.overlays = [
    #   (import ./overlays/my-global-overlay.nix)
    # ];
  };
}
