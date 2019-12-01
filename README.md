# Description
A collection of WIP (Nix Package Manager)[https://nixos.org/nix/] build expressions for opencog packages.

# Usage
```bash
cd <package-name> # e.g. cogutil
nix-shell # --run 'zsh'
```

This will build the expression dependencies, place you in that shell and run code under `shellHook`.

# Updating

Open `packages/<package>.nix` and update `rev` with a commit hash, as well as `sha256`. If `sha256` is not changed, nix will use the old build version if any without throwing an error.
To get the `sha256` quickly, I change one numerical value from `sha256`, start the build and copy-paste the expected `sha256` output from the error message.

# Debugging

Calling `nix-shell` builds the expression dependencies and places you in a shell that has them.
If `nix-shell <package>/default.nix` fails you can debug the failing package directly with its expression, located in `packages/<package>.nix`, something like:
```
rm -rf ./source # cleanup previous build
nix-shell ../path/to/packages/<package>.nix --pure # --pure is almost pure, still loads .bashrc and stuff
```

After changing the <package>.nix make sure to exit the shell if inside and repeat the above to load up the new updated expression.

Once inside the shell:
- `source` directory will be created, with `build` directory inside.
- You can call all stages by hand, like `genericBuild`. Call `type genericBuild` to see its code.
- When something fails, you will still be in the shell and can change files and retry calling a certain phase.
- before retrying a phase,`cd` back to the appropriate folder like `build` or other folders might be created nested.
- You can change the source files like `.cxxtest` or `.cpp` tests and call `checkPhase` from `build` folder.
- To get verbose output of tests go to the `source/build/tests` and call `ctest --verbose # -V`.
- Target specific tests with `ctest --tests-regex # -R`
- In SomeTest.cxxtest file replace logger level INFO with DEBUG to get `logger().set_level(Logger::DEBUG);`
- After fix is made, add it to the packages/<package>.nix and retry nix-shell with <package>/default.nix

# License
GNU Affero General Public License v3.0
