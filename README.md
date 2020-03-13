# Description
A collection of WIP [Nix Package Manager](https://nixos.org/nix/) build expressions for opencog packages.

# Usage
```bash
cd <package-name> # e.g. cogutil
nix-shell # --run 'zsh'
```

This will build the expression dependencies, place you in that shell and run code under `shellHook`.

# Updating

### Automatic update
To update all packages run `nix-shell auto-update.nix` from `packages` folder. To update only some, open `auto-update.nix` and pass package names as parameters to `update_opencog_repos`, then run the above.
This will fetch the latest master revision and its sha256 and update `packages/*.nix` files. You can then try to build them.

### Manual update
Open `packages/<package>.nix` and update `rev` with a commit hash, as well as `sha256`. If `sha256` is not changed, nix will use the old build version if any without throwing an error.
To get the `sha256` quickly, I change one numerical value from `sha256`, start the build and copy-paste the expected `sha256` output from the error message.

# Adding packages
To add a package, take a similar structure to one of the existing packages.
Read the `README.md` of the package and add all required dependencies to `buildInputs`.
Search for dependencies package attribute names [on NixOS packages](https://nixos.org/nixos/packages.html)
There might be more dependencies, you will know if the build fails.

Patching the source will most likely be required for overridings of `GUILE_LOAD_PATH` and `PYTHONPATH` in `CmakeLists.txt` files, any hardcoded path like `/usr/local/share/...`, hardcoded binary names that differ on `nixos` or some other exceptions. See `helpers/common-patch.nix`.

# Debugging

Calling `nix-shell` builds the expression dependencies and places you in a shell that has them.
If `nix-shell <package>/default.nix` fails you can debug the failing package directly with its expression, located in `packages/<package>.nix`, something like:
```
rm -rf ./source # cleanup previous build
nix-shell ../path/to/packages/<package>.nix --pure # --pure is almost pure, still loads .bashrc and stuff
```
If the patchPhase requires writting to `$out` which is read-only and possible only with `nixbld` instead of nix-shell, a custom `$out` and `$prefix` can be set: `export out=$(mktemp -d); export prefix=$out; genericBuild`

After changing the <package>.nix make sure to exit the shell if inside and repeat the above to load up the new updated expression.

Once inside the shell:
- `source` directory will be created, with `build` directory inside.
- You can call all stages by hand, like `genericBuild`. Call `type genericBuild` to see its code.
- When something fails, you will still be in the shell and can change files and retry calling a certain phase.
- before retrying a phase,`cd` back to the appropriate folder like `build` or other folders might be created nested.
- You can change the source files like `.cxxtest` or `.cpp` tests and call `checkPhase` from `build` folder.
- To get verbose output of tests go to the `source/build/tests` and call `ctest --verbose # -V`.
- Target specific tests with `ctest --tests-regex # -R`
- To get debug output prepend `logger().set_level(Logger::DEBUG); logger().set_print_to_stdout_flag(true);` to target code.
- After fix is made, add it to the packages/<package>.nix and retry nix-shell with <package>/default.nix

# License
GNU Affero General Public License v3.0
