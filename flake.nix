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

      # Define hmLib once
      hmLib = home-manager.lib; # <--- Define hmLib here

      commonSpecialArgs = {
        inherit inputs system;
        # No need to pass hmLib here for NixOS modules unless they also directly use it.
        # We will pass it to Home Manager's own extraSpecialArgs.
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
        specialArgs = commonSpecialArgs;
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
            home-manager.extraSpecialArgs = { inherit hmLib; }; # <--- PASS hmLib HERE
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
          { nixpkgs.pkgs = pkgsWithOverlays; }
          ./nixos/homelab.nix
          ./nixos/hardware-homelab.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit hmLib; }; # <--- ALSO PASS hmLib HERE if needed for homelab's HM config
            home-manager.users.death916 = {
              imports = [ ./home-manager/death916-homelab.nix ];
            };
          }
        ];
      };
    };
  };
}
