{
  description = "ibuki's NixOS + Hyprland rice (Catppuccin Mocha)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.ibuki = import ./home/ibuki.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };

      # `nix develop` — tooling for tests/check.sh and tests/format.sh.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          shellcheck
          shfmt
          nixpkgs-fmt
          statix
          deadnix
          lua
          taplo
          jq
        ];
      };

      # `nix fmt` — formats every .nix file in the tree.
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
