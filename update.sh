#!/usr/bin/env bash
set -euo pipefail

# Get latest version from GitHub
echo "Fetching latest version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/astral-sh/ty/releases/latest | jq -r .tag_name)
CURRENT_VERSION=$(nix eval --raw .#ty.version 2> /dev/null || echo "unknown")

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

if [[ $CURRENT_VERSION == "$LATEST_VERSION"   ]]; then
    echo "Already up to date"
    exit 0
fi

# Update version in flake.nix
echo "Updating version to $LATEST_VERSION..."
sed -i "s/version = \".*\";/version = \"$LATEST_VERSION\";/" flake.nix

# Fetch and update hash for each platform
declare -A PLATFORMS=(
     ["x86_64-linux"]="ty-x86_64-unknown-linux-gnu.tar.gz"
     ["i686-linux"]="ty-i686-unknown-linux-gnu.tar.gz"
     ["aarch64-linux"]="ty-aarch64-unknown-linux-gnu.tar.gz"
     ["x86_64-darwin"]="ty-x86_64-apple-darwin.tar.gz"
     ["aarch64-darwin"]="ty-aarch64-apple-darwin.tar.gz"
)

for PLATFORM in "${!PLATFORMS[@]}"; do
    ARTIFACT="${PLATFORMS[$PLATFORM]}"
    URL="https://github.com/astral-sh/ty/releases/download/$LATEST_VERSION/$ARTIFACT"

    echo "Fetching hash for $PLATFORM..."
    HASH=$(nix-prefetch-url "$URL" 2> /dev/null)
    SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

    # Find and replace the hash for this platform
    sed -i "/$PLATFORM = pkgs.fetchurl/,/hash = \"sha256-/s|hash = \"sha256-[^\"]*\";|hash = \"$SRI_HASH\";|" flake.nix

    echo "  $PLATFORM: $SRI_HASH"
done

echo "Update complete"
