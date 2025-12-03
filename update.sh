#!/usr/bin/env bash
set -euo pipefail

export NIX_PATH="nixpkgs=flake:nixpkgs"

nix-update chrome-devtools-mcp.unwrapped -f nur.nix --commit
nix-update ccusage -f nur.nix --commit
nix-update ccusage-codex -f nur.nix --commit
nix-update ccusage-mcp -f nur.nix --commit
nix-update claude-code-usage-monitor -f nur.nix --commit
nix-update kiri -f nur.nix --commit
nix-update osgrep -f nur.nix --commit

# helix-gj1118 uses builtins.getFlake, so nix-update doesn't work
./packages/helix-gj1118/update.sh --commit
