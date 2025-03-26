#!/bin/bash
# version.sh

CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Current tag: $CURRENT_TAG"

IFS='.' read -r -a parts <<< "${CURRENT_TAG//v/}"
major=${parts[0]}
minor=${parts[1]}
patch=${parts[2]}

# Default bump is patch
case "$1" in
  major) ((major++)); minor=0; patch=0 ;;
  minor) ((minor++)); patch=0 ;;
  patch|*) ((patch++)) ;;
esac

NEW_VERSION="v$major.$minor.$patch"
echo "$NEW_VERSION"
