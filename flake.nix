{
  description = "ibuki's M1 Mac nix-darwin + home-manager config (Modus Vivendi)";

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
    homebrew-brew = {
      url = "github:Homebrew/brew/7.0.7";
      flake = false;
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "homebrew-brew";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, treefmt-nix, ... }@inputs:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      forAllSystems = nixpkgs.lib.genAttrs [ linuxSystem darwinSystem ];

      # `nix fmt` runs every formatter declared in ./treefmt.nix.
      treefmtEval = forAllSystems (system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );

      mkDarwin = username: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username; };
        modules = [
          ./darwin/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username;
              enableRosetta = false;
              autoMigrate = true;
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
      darwinConfigurations = {
        ibuki = mkDarwin "ibuki";
        yoshida = mkDarwin "yoshida";
      };

      homeConfigurations = {
        "ibuki@mac" = mkDarwinHome "ibuki";
        "yoshida@mac" = mkDarwinHome "yoshida";
      };

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # formatters (one wrapper = everything in treefmt.nix)
              treefmtEval.${system}.config.build.wrapper
              # linters used by tests/check.sh
              shellcheck
              statix
              deadnix
              lua
              taplo
              jq
              biome
            ];
          };
        });

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      # `nix build .#checks.<system>.formatting` fails if any file is unformatted.
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
}
