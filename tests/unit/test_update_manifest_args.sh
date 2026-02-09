#!/usr/bin/env bash
# Unit tests for update-manifest.sh
# Tests argument validation, JSON manipulation, URL updates, and error handling
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/test-helpers.sh"

UPDATE_SCRIPT="$REPO_DIR/scripts/update-manifest.sh"

# Helper: create a mock environment
setup_manifest_env() {
    mkdir -p "$_TEST_DIR/bin"

    # Mock curl - returns a fixed hash by default
    cat > "$_TEST_DIR/bin/curl" <<'MOCK'
#!/usr/bin/env bash
echo "deadbeef0123456789abcdef0123456789abcdef0123456789abcdef01234567  file.zip"
MOCK
    chmod +x "$_TEST_DIR/bin/curl"

    # Mock git (for git diff at end)
    cat > "$_TEST_DIR/bin/git" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
    chmod +x "$_TEST_DIR/bin/git"
}

# Run update-manifest.sh with mocked PATH
run_update() {
    (cd "$_TEST_DIR" && PATH="$_TEST_DIR/bin:$PATH" bash "$UPDATE_SCRIPT" "$@" 2>&1)
}

#==============================================================================
# Tests: argument validation
#==============================================================================

test_missing_args_exits_nonzero() {
    local output exit_code=0
    output=$(bash "$UPDATE_SCRIPT" 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no arguments"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_missing_version_exits_nonzero() {
    local output exit_code=0
    output=$(bash "$UPDATE_SCRIPT" cass 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no version"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_unknown_tool_exits_nonzero() {
    setup_manifest_env
    local output exit_code=0
    output=$(run_update nonexistent 1.0.0) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail for unknown tool"
    # Script checks file existence before tool case, so error is "not found"
    assert_contains "$output" "not found" "Should report manifest not found"
}

test_missing_manifest_file_exits_nonzero() {
    setup_manifest_env
    local output exit_code=0
    output=$(run_update cass 1.0.0) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail when manifest file missing"
    assert_contains "$output" "not found" "Should mention file not found"
}

#==============================================================================
# Tests: version handling
#==============================================================================

test_version_strip_v_prefix() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.0/tool.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    local exit_code=0
    run_update cass v0.2.0 > /dev/null || exit_code=$?

    assert_equals "0" "$exit_code" "Should succeed"
    local version
    version=$(jq -r '.version' "$_TEST_DIR/cass.json")
    assert_equals "0.2.0" "$version" "Version should strip v prefix"
}

#==============================================================================
# Tests: architecture-specific manifest (cass)
#==============================================================================

test_cass_updates_version_hash_url() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.50",
    "description": "Coding Agent Session Search",
    "homepage": "https://github.com/Dicklesworthstone/coding_agent_session_search",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v0.1.50/coding-agent-search-x86_64-pc-windows-msvc.zip",
            "hash": "sha256:oldhash"
        }
    }
}
JSON

    local exit_code=0
    run_update cass 0.1.55 > /dev/null || exit_code=$?

    assert_equals "0" "$exit_code" "cass update should succeed"

    local version hash url
    version=$(jq -r '.version' "$_TEST_DIR/cass.json")
    hash=$(jq -r '.architecture."64bit".hash' "$_TEST_DIR/cass.json")
    url=$(jq -r '.architecture."64bit".url' "$_TEST_DIR/cass.json")

    assert_equals "0.1.55" "$version" "Version updated"
    assert_contains "$hash" "deadbeef" "Hash updated from curl"
    assert_contains "$url" "v0.1.55" "URL version updated"
    assert_not_contains "$url" "v0.1.50" "Old version removed from URL"
}

test_cass_preserves_all_fields() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.50",
    "description": "Test tool",
    "homepage": "https://example.com",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.50/tool.zip",
            "hash": "sha256:old"
        }
    },
    "checkver": {
        "github": "https://github.com/example/tool"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/example/releases/download/v$version/tool.zip"
            }
        }
    }
}
JSON

    run_update cass 0.2.0 > /dev/null

    assert_json_field "$(cat "$_TEST_DIR/cass.json")" '.description' "Test tool" "description preserved"
    assert_json_field "$(cat "$_TEST_DIR/cass.json")" '.homepage' "https://example.com" "homepage preserved"
    assert_json_field "$(cat "$_TEST_DIR/cass.json")" '.license' "MIT" "license preserved"
    assert_json_field "$(cat "$_TEST_DIR/cass.json")" '.checkver.github' "https://github.com/example/tool" "checkver preserved"
}

#==============================================================================
# Tests: xf (SHA256SUMS file)
#==============================================================================

test_xf_parses_sha256sums() {
    setup_manifest_env

    # Mock curl to return SHA256SUMS content
    cat > "$_TEST_DIR/bin/curl" <<'MOCK'
#!/usr/bin/env bash
cat <<'SUMS'
aaaa0000000000000000000000000000000000000000000000000000aaaa0000  xf-aarch64-apple-darwin.tar.xz
bbbb0000000000000000000000000000000000000000000000000000bbbb0000  xf-x86_64-pc-windows-msvc.zip
dddd0000000000000000000000000000000000000000000000000000dddd0000  xf-x86_64-unknown-linux-gnu.tar.xz
SUMS
MOCK
    chmod +x "$_TEST_DIR/bin/curl"

    cat > "$_TEST_DIR/xf.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/Dicklesworthstone/xf/releases/download/v0.1.0/xf-x86_64-pc-windows-msvc.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    local exit_code=0
    run_update xf 0.2.0 > /dev/null || exit_code=$?

    assert_equals "0" "$exit_code" "xf update should succeed"

    local hash
    hash=$(jq -r '.architecture."64bit".hash' "$_TEST_DIR/xf.json")
    assert_contains "$hash" "bbbb" "Should use windows-msvc checksum from SHA256SUMS"
}

#==============================================================================
# Tests: cm (simple manifest)
#==============================================================================

test_cm_updates_simple_manifest() {
    setup_manifest_env
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
    "version": "0.2.0",
    "description": "CASS Memory System",
    "url": "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v0.2.0/cass-memory-windows-x64.exe#/cm.exe",
    "hash": "sha256:oldhash",
    "bin": "cm.exe"
}
JSON

    local exit_code=0
    run_update cm 0.3.0 > /dev/null || exit_code=$?

    assert_equals "0" "$exit_code" "cm update should succeed"

    local version hash url
    version=$(jq -r '.version' "$_TEST_DIR/cm.json")
    hash=$(jq -r '.hash' "$_TEST_DIR/cm.json")
    url=$(jq -r '.url' "$_TEST_DIR/cm.json")

    assert_equals "0.3.0" "$version" "Version updated"
    assert_contains "$hash" "deadbeef" "Hash updated"
    assert_contains "$url" "v0.3.0" "URL version updated"
    assert_not_contains "$url" "v0.2.0" "Old version removed from URL"
}

test_cm_preserves_rename_fragment() {
    setup_manifest_env
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
    "version": "0.2.0",
    "url": "https://github.com/example/releases/download/v0.2.0/cass-memory-windows-x64.exe#/cm.exe",
    "hash": "sha256:old"
}
JSON

    run_update cm 0.3.0 > /dev/null

    local url
    url=$(jq -r '.url' "$_TEST_DIR/cm.json")
    assert_contains "$url" "#/cm.exe" "Rename fragment preserved"
}

test_cm_preserves_bin_field() {
    setup_manifest_env
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
    "version": "0.2.0",
    "url": "https://github.com/example/releases/download/v0.2.0/tool.exe",
    "hash": "sha256:old",
    "bin": "cm.exe"
}
JSON

    run_update cm 0.3.0 > /dev/null

    assert_json_field "$(cat "$_TEST_DIR/cm.json")" '.bin' "cm.exe" "bin field preserved"
}

#==============================================================================
# Tests: JSON validity
#==============================================================================

test_output_is_valid_json_arch() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.0/tool.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    run_update cass 0.2.0 > /dev/null

    local exit_code=0
    jq . "$_TEST_DIR/cass.json" > /dev/null 2>&1 || exit_code=$?
    assert_equals "0" "$exit_code" "Output should be valid JSON"
}

test_output_is_valid_json_simple() {
    setup_manifest_env
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
    "version": "0.1.0",
    "url": "https://github.com/example/releases/download/v0.1.0/tool.exe",
    "hash": "sha256:old"
}
JSON

    run_update cm 0.2.0 > /dev/null

    local exit_code=0
    jq . "$_TEST_DIR/cm.json" > /dev/null 2>&1 || exit_code=$?
    assert_equals "0" "$exit_code" "Output should be valid JSON"
}

#==============================================================================
# Tests: idempotency
#==============================================================================

test_idempotent_cass_update() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.0/tool.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    run_update cass 0.2.0 > /dev/null
    local hash1
    hash1=$(sha256sum "$_TEST_DIR/cass.json" | cut -d' ' -f1)

    run_update cass 0.2.0 > /dev/null
    local hash2
    hash2=$(sha256sum "$_TEST_DIR/cass.json" | cut -d' ' -f1)

    assert_equals "$hash1" "$hash2" "Same update should be idempotent"
}

test_idempotent_cm_update() {
    setup_manifest_env
    cat > "$_TEST_DIR/cm.json" <<'JSON'
{
    "version": "0.1.0",
    "url": "https://github.com/example/releases/download/v0.1.0/tool.exe",
    "hash": "sha256:old"
}
JSON

    run_update cm 0.2.0 > /dev/null
    local hash1
    hash1=$(sha256sum "$_TEST_DIR/cm.json" | cut -d' ' -f1)

    run_update cm 0.2.0 > /dev/null
    local hash2
    hash2=$(sha256sum "$_TEST_DIR/cm.json" | cut -d' ' -f1)

    assert_equals "$hash1" "$hash2" "Same update should be idempotent"
}

#==============================================================================
# Tests: output messages
#==============================================================================

test_shows_updating_message() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.0/tool.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    local output
    output=$(run_update cass 0.2.0)

    assert_contains "$output" "Updating cass to version 0.2.0" "Should show updating message"
    assert_contains "$output" "Manifest updated" "Should confirm update"
}

test_shows_checksum_value() {
    setup_manifest_env
    cat > "$_TEST_DIR/cass.json" <<'JSON'
{
    "version": "0.1.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/example/releases/download/v0.1.0/tool.zip",
            "hash": "sha256:old"
        }
    }
}
JSON

    local output
    output=$(run_update cass 0.2.0)

    assert_contains "$output" "Checksum:" "Should display checksum"
}

test_supported_tools_in_error_msg() {
    setup_manifest_env
    # Create a manifest file so we get past the file check into the case statement
    echo '{}' > "$_TEST_DIR/badtool.json"

    local output exit_code=0
    output=$(run_update badtool 1.0.0) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail for unsupported tool"
    assert_contains "$output" "Supported tools" "Should list supported tools"
}

#==============================================================================
# Run all tests
#==============================================================================

run_test test_missing_args_exits_nonzero
run_test test_missing_version_exits_nonzero
run_test test_unknown_tool_exits_nonzero
run_test test_missing_manifest_file_exits_nonzero
run_test test_version_strip_v_prefix
run_test test_cass_updates_version_hash_url
run_test test_cass_preserves_all_fields
run_test test_xf_parses_sha256sums
run_test test_cm_updates_simple_manifest
run_test test_cm_preserves_rename_fragment
run_test test_cm_preserves_bin_field
run_test test_output_is_valid_json_arch
run_test test_output_is_valid_json_simple
run_test test_idempotent_cass_update
run_test test_idempotent_cm_update
run_test test_shows_updating_message
run_test test_shows_checksum_value
run_test test_supported_tools_in_error_msg

print_results
