# ~/Documents/nix-config/flake.nix
{
  description = "NixOS configurations for laptop and homelab server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # Added for Home Assistant

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flox.url = "github:flox/flox";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      rust-overlay,
      flox,
      ...
    }:
    let
      system = "x86_64-linux";
      hmLib = home-manager.lib;
      primaryUser = "death916";

      overlays = {
        rust = rust-overlay.overlays.default;
        halloy = import ./overlays/halloy-overlay.nix;
      };

    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              overlays
              primaryUser
              ;
            unstablePkgs = import nixpkgs-unstable { inherit system; };
          };
          modules = [
            ./nixos/configuration.nix
            ./nixos/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            (
              { unstablePkgs, ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit hmLib unstablePkgs; };
                home-manager.users.death916 = {
                  imports = [ ./home-manager/home.nix ];
                };
              }
            )
          ];
        };

        homelab = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              overlays
              primaryUser
              ;
            unstablePkgsHA = import nixpkgs-unstable { inherit system; };
          };
          modules = [
            ./nixos/homelab.nix # Your main homelab config
            ./nixos/hardware-homelab.nix
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

        oracle-proxy = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit
              inputs
              system
              overlays
              primaryUser
              ;
          };
          modules = [
            ./nixos/oracle-proxy.nix # Your main homelab config
            ./nixos/oracle-proxy-hardware.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit hmLib; };
              home-manager.users.death916 = {
                imports = [ ./home-manager/oracle-proxy-home.nix ];
              };
            }
          ];
        };

        orac = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          specialArgs = {
            inherit
              inputs
              overlays
              primaryUser
              ;
            system = "aarch64-linux";
          };
          modules = [
            ./nixos/orac.nix # Your main homelab config
            ./nixos/orac-hardware.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit hmLib; };
              home-manager.users.death916 = {
                imports = [ ./home-manager/orac-home.nix ];
              };
            }
          ];
        };
      };
    };
}
