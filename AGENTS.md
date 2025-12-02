# Repository Guidelines

## Project Structure & Module Organization

- Nix flake repo. Key paths:
  - `flake.nix` / `flake.lock`: flake entry + pins
  - `packages/<name>/{default.nix,package.nix}`: per‑package definitions
  - `modules/{home,nixos}/*.nix`: Home Manager/NixOS modules
  - `nur.nix`: maintained package/module index
  - `docs/`: user docs; update when behavior changes

## Scripts

```sh
# Enter dev shell
# No action required, automatically done via .envrc

# Format all files
nix fmt # uses treefmt

# Build a package
nix build .#<name> # example: nix build .#osgrep
```

## Coding Style & Naming Conventions

- Naming: directories/attrs use kebab‑case (e.g., `osgrep`); keep `default.nix` thin; put logic in `package.nix`.
- One package per folder; modules end with `.nix` and expose options under clear namespaces (e.g., `programs.osgrep`).

## Testing Guidelines

- No dedicated unit test framework. Validate by building:
  - `nix build .#<name>` for packages
  - For modules, smoke‑test in a throwaway HM/NixOS config.
- Keep derivations reproducible; avoid network access at build time.

## Commit & Pull Request Guidelines

- Commit style: imperative, lowercase; scope prefix.
  - Examples: `packages: init osgrep`, `packages/osgrep: fixed XXX`, `modules: init osgrep`, `gh action: update cachix`
