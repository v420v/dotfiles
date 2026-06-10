{
  description = "ibuki's NixOS + Hyprland rice (Modus Vivendi) + M1 Mac home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declaratively installs & manages Homebrew itself (for GUI app casks).
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, ... }@inputs:
    let
      # The NixOS box is x86_64-linux; the Mac is aarch64-darwin. devShell and
      # formatter are exposed for both (CI runs the x86_64-linux one).
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      forAllSystems = nixpkgs.lib.genAttrs [ linuxSystem darwinSystem ];

      # Both Macs (personal `ibuki`, work `yoshida`) build from the same
      # modules — only the username/home dir differ. `mkDarwin` threads the
      # username through to darwin/configuration.nix and home/darwin.nix so
      # nothing is hardcoded. Apply with: darwin-rebuild switch --flake ~/dotfiles#<username>
      mkDarwin = username: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username; };
        modules = [
          ./darwin/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username; # owns the /opt/homebrew prefix
              enableRosetta = false; # all our casks have native arm64 builds
              autoMigrate = true; # adopt a pre-existing brew install if found
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.${username} = import ./home/darwin.nix;
            home-manager.extraSpecialArgs = { inherit inputs username; };
          }
        ];
      };

      # Standalone home-manager (no-sudo, user-only) for either Mac username.
      # Apply with: home-manager switch --flake ~/dotfiles#<username>@mac
      mkDarwinHome = username: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = darwinSystem;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs username; };
        modules = [ ./home/darwin.nix ];
      };
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
            home-manager.extraSpecialArgs = { inherit inputs; username = "ibuki"; };
          }
        ];
      };

      # ---------- M1 Macs: nix-darwin + home-manager (primary) ----------
      # System + user in one rebuild, mirroring the NixOS host. One entry per
      # machine, keyed by login username:
      #   ibuki   — personal MacBook
      #   yoshida — work MacBook
      # Apply with: darwin-rebuild switch --flake ~/dotfiles#<username>
      darwinConfigurations = {
        ibuki = mkDarwin "ibuki";
        yoshida = mkDarwin "yoshida";
      };

      # ---------- M1 Macs: standalone home-manager (no-sudo alternative) ----------
      # Same home/darwin.nix as above, for user-only changes without touching
      # the system. Apply with: home-manager switch --flake ~/dotfiles#<username>@mac
      # allowUnfree is set on the pkgs we pass in (claude-code is unfree); the
      # NixOS host and nix-darwin host set the same flag in their system config.
      homeConfigurations = {
        "ibuki@mac" = mkDarwinHome "ibuki";
        "yoshida@mac" = mkDarwinHome "yoshida";
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
