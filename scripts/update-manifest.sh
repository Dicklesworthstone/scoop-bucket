#!/usr/bin/env bash
# Update every declared architecture in a Scoop manifest only after all assets
# have been downloaded and verified. Flat manifests are also supported.
# Usage: ./update-manifest.sh <tool> <version> [options]
#   --manifest <path>  Read this manifest instead of <bucket>/<tool>.json.
#   --output <path>    Write a fresh candidate; never replace the input manifest.
#   --work-root <dir>  Create a unique working directory under this existing dir.
#   --retain-work      Keep downloads/records (requires --work-root and --output).
#
# For a non-mutating, retained run:
#   ./update-manifest.sh dcg 0.15.3 --manifest dcg.json \
#     --output /path/to/fresh/dcg.json --work-root /external/owned-dir --retain-work
#
# Hashes are computed from real assets and checked against published .sha256
# sidecars when available. A missing asset, malformed hash, or sidecar mismatch
# leaves the input untouched and creates no output manifest (scoop-bucket#5/#6).
# Existing URL/hash arrays are rejected explicitly rather than partially updated.
set -euo pipefail

usage() {
  echo "Usage: $0 <tool> <version> [--manifest <path>] [--output <fresh path>] [--work-root <existing dir>] [--retain-work]" >&2
}

TOOL="${1:-}"
VERSION="${2:-}"
if [[ -z "$TOOL" || -z "$VERSION" ]]; then
  usage
  exit 2
fi
shift 2
MANIFEST_OVERRIDE=""
OUTPUT_FILE=""
WORK_ROOT=""
RETAIN_WORK=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest|--output|--work-root)
      [[ $# -ge 2 && -n "$2" ]] || { usage; exit 2; }
      case "$1" in
        --manifest) MANIFEST_OVERRIDE="$2" ;;
        --output) OUTPUT_FILE="$2" ;;
        --work-root) WORK_ROOT="$2" ;;
      esac
      shift 2 ;;
    --retain-work) RETAIN_WORK=1; shift ;;
    *) echo "Error: unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

VERSION="${VERSION#v}"
if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)*([.-][0-9A-Za-z.]+)?$ ]]; then
  echo "Error: '$VERSION' does not look like a release version" >&2
  exit 2
fi
if [[ "$RETAIN_WORK" == 1 && ( -z "$WORK_ROOT" || -z "$OUTPUT_FILE" ) ]]; then
  echo "Error: --retain-work requires --work-root and --output" >&2
  exit 2
fi
if [[ -n "$WORK_ROOT" && ! -d "$WORK_ROOT" ]]; then
  echo "Error: working root is not an existing directory: $WORK_ROOT" >&2
  exit 2
fi
if [[ -n "$OUTPUT_FILE" && ( -e "$OUTPUT_FILE" || -L "$OUTPUT_FILE" ) ]]; then
  echo "Error: output must be a fresh path: $OUTPUT_FILE" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUCKET_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="${MANIFEST_OVERRIDE:-$BUCKET_DIR/${TOOL}.json}"
if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Error: Manifest file not found: $MANIFEST_FILE" >&2
  exit 1
fi
for dep in curl jq; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Error: required tool not found: $dep" >&2; exit 1; }
done

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    echo "Error: neither sha256sum nor shasum is available" >&2
    return 1
  fi
}

if [[ -n "$WORK_ROOT" ]]; then
  WORK_DIR="$(mktemp -d "$WORK_ROOT/scoop-update.XXXXXXXX")"
else
  WORK_DIR="$(mktemp -d)"
fi
cleanup() {
  if [[ "$RETAIN_WORK" == 1 ]]; then
    echo "Retained work: $WORK_DIR"
  else
    rm -rf "$WORK_DIR"
  fi
}
trap cleanup EXIT

# Read one snapshot throughout; fail if the live input changes before writing.
cat "$MANIFEST_FILE" > "$WORK_DIR/input.json"
INPUT_HASH="$(sha256_file "$WORK_DIR/input.json")"
if jq -e 'has("architecture")' "$WORK_DIR/input.json" >/dev/null; then
  ARCH_KEYED=1
  jq -e '.architecture | type == "object" and length > 0' "$WORK_DIR/input.json" >/dev/null || {
    echo "Error: architecture must be a non-empty object" >&2; exit 1;
  }
  jq -r '.architecture | keys[]' "$WORK_DIR/input.json" > "$WORK_DIR/architectures"
else
  ARCH_KEYED=0
  printf '%s\n' flat > "$WORK_DIR/architectures"
fi

echo "Updating $TOOL to version $VERSION"
INDEX=0
while IFS= read -r ARCH; do
  INDEX=$((INDEX + 1))
  if [[ "$ARCH_KEYED" == 1 ]]; then
    CURRENT_URL="$(jq -er --arg arch "$ARCH" '.architecture[$arch].url | select(type == "string" and length > 0)' "$WORK_DIR/input.json")" || {
      echo "Error: $ARCH requires a single non-empty URL" >&2; exit 1;
    }
    TEMPLATE="$(jq -r --arg arch "$ARCH" '.autoupdate.architecture[$arch].url // .autoupdate.url // empty' "$WORK_DIR/input.json")"
  else
    CURRENT_URL="$(jq -er '.url | select(type == "string" and length > 0)' "$WORK_DIR/input.json")" || {
      echo "Error: flat manifest requires a single non-empty URL" >&2; exit 1;
    }
    TEMPLATE="$(jq -r '.autoupdate.url // empty' "$WORK_DIR/input.json")"
  fi
  jq -e --arg arch "$ARCH" --argjson keyed "$ARCH_KEYED" '
    (if $keyed == 1 then .architecture[$arch] else . end).hash | type != "array"
  ' "$WORK_DIR/input.json" >/dev/null || {
    echo "Error: $ARCH hash arrays are not supported" >&2; exit 1;
  }
  jq -e --arg arch "$ARCH" --argjson keyed "$ARCH_KEYED" '
    (if $keyed == 1 then .autoupdate.architecture[$arch].url // .autoupdate.url else .autoupdate.url end) |
    . == null or type == "string"
  ' "$WORK_DIR/input.json" >/dev/null || {
    echo "Error: $ARCH autoupdate URL must be a string" >&2; exit 1;
  }

  if [[ -n "$TEMPLATE" ]]; then
    NEW_URL="${TEMPLATE//\$version/$VERSION}"
  else
    NEW_URL="$(printf '%s' "$CURRENT_URL" | sed -E "s#/v[0-9]+(\.[0-9]+)*([.-][0-9A-Za-z.]+)?/#/v${VERSION}/#")"
  fi
  if [[ "$NEW_URL" != *"$VERSION"* ]]; then
    echo "Error: could not derive a v${VERSION} URL for $ARCH (got: $NEW_URL)" >&2
    exit 1
  fi

  # Scoop's #/name.exe fragment is a rename instruction, not a download URL.
  DOWNLOAD_URL="${NEW_URL%%#*}"
  ASSET_NAME="${DOWNLOAD_URL##*/}"
  ASSET_FILE="$WORK_DIR/asset-$INDEX"
  echo "Architecture: $ARCH"
  echo "Asset: $DOWNLOAD_URL"
  if ! curl -fsSL --retry 3 --retry-delay 2 --max-time 600 -o "$ASSET_FILE" "$DOWNLOAD_URL"; then
    echo "Error: release v${VERSION} of $TOOL does not publish $ASSET_NAME (download failed)." >&2
    echo "       No manifest was written; every declared architecture must verify." >&2
    exit 1
  fi
  [[ -s "$ASSET_FILE" ]] || { echo "Error: downloaded asset is empty: $DOWNLOAD_URL" >&2; exit 1; }
  CHECKSUM="$(sha256_file "$ASSET_FILE")"
  CHECKSUM="$(printf '%s' "$CHECKSUM" | tr '[:upper:]' '[:lower:]')"
  if [[ ! "$CHECKSUM" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Error: computed hash is not a sha256 digest: '$CHECKSUM'" >&2
    exit 1
  fi

  SIDECAR_URL="${DOWNLOAD_URL}.sha256"
  if curl -fsSL --retry 2 --max-time 60 -o "$WORK_DIR/sidecar-$INDEX" "$SIDECAR_URL" 2>/dev/null; then
    SIDECAR_HASH="$(grep -Eo '[0-9a-fA-F]{64}' "$WORK_DIR/sidecar-$INDEX" | head -n1 || true)"
    SIDECAR_HASH="$(printf '%s' "$SIDECAR_HASH" | tr '[:upper:]' '[:lower:]')"
    if [[ -z "$SIDECAR_HASH" ]]; then
      echo "Error: sidecar $SIDECAR_URL exists but contains no sha256 digest" >&2
      exit 1
    fi
    if [[ "$SIDECAR_HASH" != "$CHECKSUM" ]]; then
      echo "Error: sidecar hash disagrees with the downloaded asset" >&2
      echo "       sidecar:  $SIDECAR_HASH" >&2
      echo "       computed: $CHECKSUM" >&2
      exit 1
    fi
    echo "Checksum: $CHECKSUM (matches published .sha256 sidecar)"
  else
    echo "Checksum: $CHECKSUM (computed locally; no .sha256 sidecar published)"
  fi
  jq -n --arg arch "$ARCH" --arg url "$NEW_URL" --arg hash "$CHECKSUM" \
    '{architecture: $arch, url: $url, hash: $hash}' > "$WORK_DIR/verified-$INDEX.json"
done < "$WORK_DIR/architectures"

# Only reach here after EVERY declared architecture has verified. Preserve all
# fields other than version and the verified download URLs/hashes.
jq -s '.' "$WORK_DIR"/verified-*.json > "$WORK_DIR/verified.json"
jq --indent 2 --arg version "$VERSION" --argjson keyed "$ARCH_KEYED" \
  --slurpfile verified "$WORK_DIR/verified.json" '
  .version = $version |
  reduce $verified[0][] as $asset (.;
    if $keyed == 1 then
      .architecture[$asset.architecture].url = $asset.url |
      .architecture[$asset.architecture].hash = $asset.hash
    else .url = $asset.url | .hash = $asset.hash end)
' "$WORK_DIR/input.json" > "$WORK_DIR/candidate.json"
if [[ "$(sha256_file "$MANIFEST_FILE")" != "$INPUT_HASH" ]]; then
  echo "Error: input manifest changed during verification; no manifest was written" >&2
  exit 1
fi

if [[ -n "$OUTPUT_FILE" ]]; then
  # noclobber also rejects a symlink/existing file created after the preflight.
  (set -C; cat "$WORK_DIR/candidate.json" > "$OUTPUT_FILE")
  echo "Candidate manifest written: $OUTPUT_FILE (input unchanged)"
else
  mv "$WORK_DIR/candidate.json" "$MANIFEST_FILE"
  echo "Manifest updated: $MANIFEST_FILE"
  echo "Changes:"
  git -C "$BUCKET_DIR" --no-pager diff -- "${TOOL}.json" || true
fi
