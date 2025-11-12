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
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      rust-overlay,
      flox,
      hyprland,
      ...
    }:
    let
      hmLib = home-manager.lib;
      primaryUser = "death916";

      overlays = {
        rust = rust-overlay.overlays.default;
        halloy = import ./overlays/halloy-overlay.nix;
        waveterm = import ./overlays/waveterm-overlay.nix;
      };

    in
    {
      nixConfig = {
        substituters = [
          "https://cache.nixos.org/"
          "https://hyprland.cachix.org"
          "https://cache.flox.dev"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvu4F0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      nixosConfigurations = {
        nixos =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                system
                overlays
                primaryUser
                hyprland # Pass hyprland to specialArgs
                ;
              unstablePkgs = import nixpkgs-unstable { inherit system; };
            };
            modules = [
              {
                nixpkgs.overlays = [
                  overlays.waveterm
                  overlays.rust
                  overlays.halloy
                ];
              }
              ./nixos/configuration.nix
              ./nixos/hardware-configuration.nix
              home-manager.nixosModules.home-manager
              (
                { unstablePkgs, ... }:
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "backup";
                  home-manager.extraSpecialArgs = { inherit hmLib unstablePkgs inputs; };
                  home-manager.users.death916 = {
                    imports = [
                      ./home-manager/home.nix
                    ];
                  };
                }
              )
            ];
          };

        homelab =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
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
              (
                { unstablePkgsHA, ... }:
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit hmLib unstablePkgsHA inputs; };
                  home-manager.users.death916 = {
                    imports = [ ./home-manager/death916-homelab.nix ];
                  };
                }
              )
            ];
          };

        oracle-proxy =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
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

        orac =
          let
            system = "aarch64-linux";
          in
          nixpkgs.lib.nixosSystem {
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
