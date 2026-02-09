#!/usr/bin/env bash
# Unit tests for update-manifest.sh argument handling
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/test-helpers.sh"

#==============================================================================
# Tests: argument validation
#==============================================================================

test_missing_args_exits_nonzero() {
    setup_test "missing args exits nonzero"

    local output exit_code=0
    output=$(bash "$REPO_DIR/scripts/update-manifest.sh" 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no arguments"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_missing_version_exits_nonzero() {
    setup_test "missing version exits nonzero"

    local output exit_code=0
    output=$(bash "$REPO_DIR/scripts/update-manifest.sh" cass 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no version"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_unknown_tool_exits_nonzero() {
    setup_test "unknown tool exits nonzero"

    # Run from temp dir where no manifest exists
    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-manifest.sh" nonexistent 1.0.0 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail for unknown tool"
}

test_missing_manifest_file_exits_nonzero() {
    setup_test "missing manifest file exits nonzero"

    # Run from temp dir where cass.json doesn't exist
    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-manifest.sh" cass 1.0.0 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail when manifest file missing"
    assert_contains "$output" "not found" "Should mention file not found"
}

test_arch_manifest_update() {
    setup_test "architecture-specific manifest update"

    # Create a mock architecture manifest
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
  "version": "0.1.0",
  "description": "Test tool",
  "homepage": "https://example.com",
  "architecture": {
    "64bit": {
      "url": "https://github.com/example/releases/download/v0.1.0/tool-x86_64-pc-windows-msvc.zip",
      "hash": "sha256:oldchecksum123"
    }
  }
}
JSON

    # Mock curl to return a fake checksum
    curl() {
        echo "deadbeef0123456789abcdef0123456789abcdef0123456789abcdef01234567  -"
    }
    export -f curl

    # Mock git
    git() { return 0; }
    export -f git

    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-manifest.sh" cass 0.2.0 2>&1) || exit_code=$?

    assert_equals "0" "$exit_code" "Should succeed"

    # Verify version was updated
    local new_version
    new_version=$(jq -r '.version' "$_TEST_DIR/cass.json")
    assert_equals "0.2.0" "$new_version" "Version should be updated"

    # Verify hash was updated
    local new_hash
    new_hash=$(jq -r '.architecture."64bit".hash' "$_TEST_DIR/cass.json")
    assert_contains "$new_hash" "deadbeef" "Hash should be updated"

    unset -f curl git
}

test_simple_manifest_update() {
    setup_test "simple manifest update"

    # Create a mock simple manifest (no architecture block)
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
  "version": "0.1.0",
  "description": "Test tool",
  "homepage": "https://example.com",
  "url": "https://github.com/example/releases/download/v0.1.0/tool-windows-x64.exe",
  "hash": "sha256:oldchecksum123"
}
JSON

    # Mock curl
    curl() {
        echo "cafebabe0123456789abcdef0123456789abcdef0123456789abcdef01234567  -"
    }
    export -f curl

    # Mock git
    git() { return 0; }
    export -f git

    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-manifest.sh" cm 0.3.0 2>&1) || exit_code=$?

    assert_equals "0" "$exit_code" "Should succeed"

    local new_version
    new_version=$(jq -r '.version' "$_TEST_DIR/cm.json")
    assert_equals "0.3.0" "$new_version" "Version should be updated"

    unset -f curl git
}

#==============================================================================
# Run all tests
#==============================================================================

run_test test_missing_args_exits_nonzero
run_test test_missing_version_exits_nonzero
run_test test_unknown_tool_exits_nonzero
run_test test_missing_manifest_file_exits_nonzero
run_test test_arch_manifest_update
run_test test_simple_manifest_update

print_results
