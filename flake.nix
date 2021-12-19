{
  description = "A flake template for Phoenix 1.6 projects.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?ref=master;
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: 
    let
    pkgsForSystem = system: import nixpkgs {
        overlays = [ overlay ];
        inherit system;
      };

    overlay = final: prev: rec {

      my-phx-project = with final;
        let
          beamPackages = beam.packagesWith beam.interpreters.erlangR24; 
          mixNixDeps = import ./deps.nix { inherit lib beamPackages; }; 
        in beamPackages.mixRelease {
          inherit mixNixDeps;
          pname = "my-phx-project";
          src = ./.;
          version = "0.0.0";
          RELEASE_DISTRIBUTION = "none";
         };
    };
    in utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) my-phx-project;
      };
      defaultPackage = packages.my-phx-project;
      devShell = self.devShells.${system}.dev;
      devShells = {
        dev = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_dev";
          MIX_ENV = "dev";
        };
        test = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_test";
          MIX_ENV = "test";
        };
          prod = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_prod";
          MIX_ENV = "prod";
        };
      };
      apps.my-phx-project = utils.lib.mkApp { drv = packages.my-phx-project; };
      hydraJobs = { inherit (legacyPackages) my-phx-project; };
      checks = { inherit (legacyPackages) my-phx-project; };
    }) // { overlay = overlay ;};
}
