#!/bin/bash
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

IFS='.' read -r -a parts <<< "${CURRENT_TAG//v/}"
major=${parts[0]:-0}
minor=${parts[1]:-0}
patch=${parts[2]:-0}

case "$1" in
  major) ((major++)); minor=0; patch=0 ;;
  minor) ((minor++)); patch=0 ;;
  patch|*) ((patch++)) ;;
esac

echo "v$major.$minor.$patch"
