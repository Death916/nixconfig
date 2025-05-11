{
  description = "Base NixOS flake";

  inputs = {
    # MODIFIED: Main Nixpkgs explicitly set to the nixos-24.11 branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # The nixos-cosmic flake input
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      # MODIFIED: nixos-cosmic will now use the nixpkgs defined above (nixos-24.11)
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home manager
    home-manager = {
      # MODIFIED: Explicitly set to release-24.11
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Home Manager will use the nixpkgs defined above (nixos-24.11)
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-cosmic, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        modules = [
          {
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
            };
          }
        ];
      };
    };
  };
}
