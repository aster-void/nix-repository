#!/usr/bin/env bash
set -euo pipefail

export NIX_PATH="nixpkgs=flake:nixpkgs"

# Updates a package, verifies build, and pushes if successful
# Usage: update_package <nix-attr> [build-attr]
# If build-attr is not provided, uses nix-attr
update_package() {
  local nix_attr="$1"
  local build_attr="${2:-$1}"
  local commit_before
  commit_before=$(git rev-parse HEAD)

  echo "=== Updating $nix_attr ==="

  if ! nix-update "$nix_attr" --flake --commit; then
    echo "WARNING: nix-update failed for $nix_attr, skipping"
    return 0
  fi

  # Check if a new commit was created
  if [ "$(git rev-parse HEAD)" = "$commit_before" ]; then
    echo "INFO: No update for $nix_attr"
    return 0
  fi

  if ! nix build ".#$build_attr" --print-build-logs; then
    echo "ERROR: Build failed for $build_attr, reverting commit"
    git reset --hard HEAD~1
    return 0
  fi

  # Run per-package check script if exists
  if [ -x "./packages/$build_attr/check.sh" ]; then
    echo "Running check script for $build_attr..."
    if ! "./packages/$build_attr/check.sh"; then
      echo "ERROR: Check failed for $build_attr, reverting commit"
      git reset --hard HEAD~1
      return 0
    fi
  fi

  echo "SUCCESS: $nix_attr updated and verified"
  git push
}

# Updates helix-gj1118 using its custom script
update_helix() {
  local commit_before
  commit_before=$(git rev-parse HEAD)

  echo "=== Updating helix-gj1118 ==="

  if ! ./packages/helix-gj1118/update.sh --commit; then
    echo "WARNING: helix-gj1118 update failed, skipping"
    return 0
  fi

  # Check if a new commit was created
  if [ "$(git rev-parse HEAD)" = "$commit_before" ]; then
    echo "INFO: No update for helix-gj1118"
    return 0
  fi

  if ! nix build ".#helix-gj1118" --print-build-logs; then
    echo "ERROR: Build failed for helix-gj1118, reverting commit"
    git reset --hard HEAD~1
    return 0
  fi

  # Run per-package check script if exists
  if [ -x "./packages/helix-gj1118/check.sh" ]; then
    echo "Running check script for helix-gj1118..."
    if ! "./packages/helix-gj1118/check.sh"; then
      echo "ERROR: Check failed for helix-gj1118, reverting commit"
      git reset --hard HEAD~1
      return 0
    fi
  fi

  echo "SUCCESS: helix-gj1118 updated and verified"
  git push
}

update_package chrome-devtools-mcp.unwrapped chrome-devtools-mcp
update_package ccusage
update_package ccusage-codex
update_package ccusage-mcp
update_package claude-code-usage-monitor
update_package kiri
update_package osgrep
update_package climcp
update_helix
