#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

echo "Fetching latest commit from aster-void/zz..."
LATEST_REV=$(curl -s "https://api.github.com/repos/aster-void/zz/commits/main" | jq -r '.sha')

if [ -z "$LATEST_REV" ] || [ "$LATEST_REV" = "null" ]; then
  echo "Error: Failed to fetch latest commit hash" >&2
  exit 1
fi

echo "Latest revision: $LATEST_REV"

CURRENT_REV=$(grep -oP 'rev = "\K[^"]+' "$PACKAGE_FILE")
echo "Current revision: $CURRENT_REV"

if [ "$CURRENT_REV" = "$LATEST_REV" ]; then
  echo "Already up to date!"
  exit 0
fi

sed -i "s/rev = \"$CURRENT_REV\"/rev = \"$LATEST_REV\"/" "$PACKAGE_FILE"

nix fmt "$PACKAGE_FILE" 2>/dev/null || true

echo "Updated zz from $CURRENT_REV to $LATEST_REV"
