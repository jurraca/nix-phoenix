with import <nixpkgs> {};

let
  phx_new =  beamPackages.buildMix rec {
      name = "phx_new";
      version = "1.6.0";
      src = fetchHex {
      pkg = "phx_new";
      version = "1.6.0";
      sha256 = "2664453aba6a02b212724419af8d09e0437eb640e2725bd43f0d2201d9a3301d";
    };

    beamDeps = [];
  };

  # define packages to install
  basePackages = [
    git
    beam.packages.erlang.elixir_1_12
    mix2nix
    postgresql_13
    phx_new
  ];

  inputs = basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  # define shell startup command
  hooks = ''
    # this allows mix to work on the local directory
    mkdir -p .nix-mix .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
    # TODO: not sure how to make hex available without installing it afterwards.
    mix local.hex --if-missing

    export MIX_ENV=dev

    # build and install the "mix phx.new" task
    ln -sf ${phx_new}/lib/erlang/lib/phx_new-1.6.0/ebin .nix-mix/archives/phx_new/
    mix archive.build -i .nix-mix/archives/phx_new/ -o .nix-hex/phx_new.ez
    mix archive.install .nix-hex/phx_new.ez

    export LANG=en_US.UTF-8
    # keep your shell history in iex
    export ERL_AFLAGS="-kernel shell_history enabled"

    # postgres related
    # keep all your db data in a folder inside the project
    export PGDATA="$PWD/db"

    # phoenix related env vars
    export POOL_SIZE=15
    export DB_URL="postgresql://postgres:postgres@localhost:5432/db"
    export PORT=4000
    export MIX_ENV=dev
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}