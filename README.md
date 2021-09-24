## README 

A set of Nix tools to work with Elixir's Phoenix web framework, with Elixir 12 and Phoenix 1.6. The goal is reproducible builds, but we also get virtual environments with this setup. For example, one could replace `asdf` with nix shells. 

Elixir 12 and Phoenix 1.6 bring some important [changes](https://www.phoenixframework.org/blog/phoenix-1.6-released). For Nix users, the most important is probably switching out webpack for [esbuild](https://esbuild.github.io/) to handle front end dependencies, meaning no dependency on Node.js and no additional setup required when compiling a Phoenix app. A big win for reproducibility. 

The workflow looks something like this: 
- pop into a Nix shell (especially if you're using a different Elixir version): `nix-shell phx-shell.nix`. You're now in an environment which specifies Elixir 12 and sets up some env vars you would expect, as well as the `mix2nix` tool for handling Mix dependencies in Nix.
- set up your Phoenix project as you usually would: `mix phx.new my-project`. 
- copy the `flake.nix` and `shell.nix` files into your project directory.
- Notice that the flake imports a `deps.nix` file, which doesn't exist yet. This is where [mix2nix](https://github.com/ydlr/mix2nix) comes in: run `mix2nix > deps.nix`. This will look at your `mix.lock` file, query hex for the dependency binaries, and add them to the nix store. Now your environment and your build will query the nix store instead of fetching dependencies externally. Reproducibility win. 
- You can now run `nix build` to build a Mix release (which will be under `result/bin/my-project-name`) or hack on the project further with `nix develop`. Check out the [flake docs](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html) for more commands.

