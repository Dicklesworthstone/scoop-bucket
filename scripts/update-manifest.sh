#!/usr/bin/env bash
# Auto-update Scoop manifest for a specific tool
# Usage: ./update-manifest.sh <tool> <version>
set -euo pipefail

TOOL="${1:-}"
VERSION="${2:-}"

if [[ -z "$TOOL" || -z "$VERSION" ]]; then
  echo "Usage: $0 <tool> <version>"
  echo "Example: $0 cass 0.1.56"
  exit 1
fi

# Strip 'v' prefix if present
VERSION="${VERSION#v}"

MANIFEST_FILE="${TOOL}.json"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Error: Manifest file not found: $MANIFEST_FILE"
  exit 1
fi

echo "Updating $TOOL to version $VERSION"

# Tool-specific update logic
case "$TOOL" in
  cass)
    URL="https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-x86_64-pc-windows-msvc.zip"
    CHECKSUM_URL="${URL}.sha256"
    echo "Fetching checksum..."
    CHECKSUM=$(curl -sL "$CHECKSUM_URL" | cut -d' ' -f1)
    ;;

  xf)
    URL="https://github.com/Dicklesworthstone/xf/releases/download/v${VERSION}/xf-x86_64-pc-windows-msvc.zip"
    SUMS=$(curl -sL "https://github.com/Dicklesworthstone/xf/releases/download/v${VERSION}/SHA256SUMS")
    CHECKSUM=$(echo "$SUMS" | grep "x86_64-pc-windows-msvc" | cut -d' ' -f1)
    ;;

  cm)
    URL="https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v${VERSION}/cass-memory-windows-x64.exe"
    CHECKSUM_URL="${URL}.sha256"
    echo "Fetching checksum..."
    CHECKSUM=$(curl -sL "$CHECKSUM_URL" | cut -d' ' -f1)
    ;;

  dcg)
    URL="https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v${VERSION}/dcg-x86_64-pc-windows-msvc.zip"
    CHECKSUM_URL="${URL}.sha256"
    echo "Fetching checksum..."
    CHECKSUM=$(curl -sL "$CHECKSUM_URL" | cut -d' ' -f1)
    ;;

  tru)
    URL="https://github.com/Dicklesworthstone/toon_rust/releases/download/v${VERSION}/toon-windows-amd64.zip"
    CHECKSUM_URL="${URL}.sha256"
    echo "Fetching checksum..."
    CHECKSUM=$(curl -sL "$CHECKSUM_URL" | cut -d' ' -f1)
    ;;

  *)
    echo "Error: Unknown tool or tool not available for Windows: $TOOL"
    echo "Supported tools: cass, xf, cm, dcg, tru"
    exit 1
    ;;
esac

echo "Checksum: $CHECKSUM"

# Update the manifest using jq (version, hash, and URL in one pass)
if jq -e '.architecture' "$MANIFEST_FILE" > /dev/null 2>&1; then
  # Architecture-specific manifest (cass, xf)
  jq --arg version "$VERSION" --arg hash "$CHECKSUM" '
    .version = $version |
    .architecture."64bit".hash = $hash |
    .architecture."64bit".url = (.architecture."64bit".url | gsub("v[0-9.]+"; "v" + $version))
  ' "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
else
  # Simple manifest (cm)
  jq --arg version "$VERSION" --arg hash "$CHECKSUM" '
    .version = $version |
    .hash = $hash |
    .url = (.url | gsub("v[0-9.]+"; "v" + $version))
  ' "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
fi
mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"

echo "Manifest updated: $MANIFEST_FILE"
echo ""
echo "Changes:"
git diff "$MANIFEST_FILE" || true
