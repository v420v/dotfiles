{
  description = "ibuki's NixOS + Hyprland rice (Modus Vivendi) + M1 Mac home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # The NixOS box is x86_64-linux; the Mac is aarch64-darwin. devShell and
      # formatter are exposed for both (CI runs the x86_64-linux one).
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      forAllSystems = nixpkgs.lib.genAttrs [ linuxSystem darwinSystem ];
    in
    {
      # ---------- NixOS host (system + user via HM module) ----------
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
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

      # ---------- M1 Mac (standalone home-manager) ----------
      # Apply with: home-manager switch --flake ~/dotfiles#ibuki@mac
      # allowUnfree is set on the pkgs we pass in (claude-code is unfree); the
      # NixOS host sets the same flag in nixos/configuration.nix.
      homeConfigurations."ibuki@mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = darwinSystem;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home/darwin.nix ];
      };

      # `nix develop` — tooling for tests/check.sh and tests/format.sh.
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
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
        });

      # `nix fmt` — formats every .nix file in the tree.
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
