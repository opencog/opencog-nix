# Description
This is a WIP build for atomspace with `nix` package manager.

# Quick start
```bash
cd scm-env
nix-shell # for a custom shell add `--run 'zsh'`
```

Running `nix-shell` will place you in an environment prepared by `scm-env/default.nix`.  
When entered it will execute code from its `shellHook`.  
You can modify the code there and re-enter nix-shell, then continue experimenting in the shell and move working parts inside `scm-env/default.nix`.

# About these expressions
`autotools.nix`, `builder.sh` and `setup.sh` are a convenient boilerplate taken from [nix-pills](https://nixos.org/nixos/nix-pills/)

`default.nix` is a [derivation](https://nixos.org/nix/manual/#ssec-derivation) expression where things like source, environment, build inputs and output paths are defined.

In short, `default.nix` uses a preset derivation imported from `autotools.nix` (which then uses `builder.sh` and `setup.sh`) that adds common build tools like `gnumake`, `gcc` etc. and merges it with a set of below defined attributes necessary for the package itself.  
These attributes are passed as environment variables available in `setup.sh` which prepares the source and does the build.

The scm-env is a shell environment with these packages and paths exposed in order to make `opencog` module available in `guile`.

# Notes
- I'm sure these could be written better, for the moment I'm trying to make it work first.

# License
GNU Affero General Public License v3.0
