# Dicklesworthstone Scoop Bucket

[![Test Manifests](https://github.com/Dicklesworthstone/scoop-bucket/actions/workflows/test-manifests.yml/badge.svg)](https://github.com/Dicklesworthstone/scoop-bucket/actions/workflows/test-manifests.yml)
[![Auto-Update](https://github.com/Dicklesworthstone/scoop-bucket/actions/workflows/auto-update.yml/badge.svg)](https://github.com/Dicklesworthstone/scoop-bucket/actions/workflows/auto-update.yml)

Scoop manifests for the **Dicklesworthstone Stack** - a collection of powerful tools designed for AI coding agents and developer productivity on Windows.

## Quick Start

```powershell
# Add the bucket
scoop bucket add dicklesworthstone https://github.com/Dicklesworthstone/scoop-bucket

# Install a tool
scoop install dicklesworthstone/cass
```

## Available Tools

### Session Search & Memory

| Tool | Description | Install |
|------|-------------|---------|
| **[cass](https://github.com/Dicklesworthstone/coding_agent_session_search)** | Cross-agent session search - Index and search AI coding agent conversations | `scoop install dicklesworthstone/cass` |
| **[xf](https://github.com/Dicklesworthstone/xf)** | X-Former - Search and analyze your Twitter/X archive data locally | `scoop install dicklesworthstone/xf` |
| **[cm](https://github.com/Dicklesworthstone/cass_memory_system)** | CASS Memory System - Persistent vector-based procedural memory for AI agents | `scoop install dicklesworthstone/cm` |

### Task Management & Agent Orchestration

| Tool | Description | Install |
|------|-------------|---------|
| **[bv](https://github.com/Dicklesworthstone/beads_viewer)** | Beads Viewer - Graph-aware task management TUI | `scoop install dicklesworthstone/bv` |
| **[caam](https://github.com/Dicklesworthstone/coding_agent_account_manager)** | Coding Agent Account Manager - Switch between AI agent accounts | `scoop install dicklesworthstone/caam` |
| **[slb](https://github.com/Dicklesworthstone/simultaneous_launch_button)** | Simultaneous Launch Button - Two-person rule for dangerous commands | `scoop install dicklesworthstone/slb` |
| **[ntm](https://github.com/Dicklesworthstone/ntm)** | Named Tmux Manager - Orchestrate AI coding agents in tmux sessions | `scoop install dicklesworthstone/ntm` |

### Safety & Encoding

| Tool | Description | Install |
|------|-------------|---------|
| **[dcg](https://github.com/Dicklesworthstone/destructive_command_guard)** | Destructive Command Guard - Safety rails for AI coding agents | `scoop install dicklesworthstone/dcg` |
| **[tru](https://github.com/Dicklesworthstone/toon_rust)** | TOON encoder/decoder - Token-Optimized Object Notation | `scoop install dicklesworthstone/tru` |

### Not Available on Windows

The following tools are Bash-based and only available on macOS/Linux via [Homebrew](https://github.com/Dicklesworthstone/homebrew-tap):

- **ru** (Repo Updater) - Bash script
- **ubs** (Ultimate Bug Scanner) - Bash script

## Tool Details

### cass - Coding Agent Session Search

Index and search your AI coding agent conversation histories across multiple tools:

```powershell
# Check setup and indexing status
cass health

# Search across all sessions
cass search "authentication bug"

# For AI agents, use robot mode
cass search "error handling" --robot --limit 10

# JSON output for programmatic use
cass search "database" --json
```

**Supported agents**: Claude Code, Cursor, Codex CLI, Gemini CLI, ChatGPT, Aider, and more.

### xf - X-Former (Twitter Search)

Search and analyze your personal Twitter/X data archive locally:

```powershell
# Setup: Download your Twitter data from Twitter settings, then:
xf --data-dir C:\path\to\twitter-archive

# Search your tweets
xf search "machine learning"

# Show archive statistics
xf stats

# Limit results
xf search "project" --limit 20
```

### cm - CASS Memory System

Persistent vector-based memory system that helps AI agents remember context across sessions:

```powershell
# Check system status
cm status

# Store a memory
cm store "The user prefers tabs over spaces"

# Recall relevant memories
cm recall "code formatting preferences"
```

## Updating Packages

```powershell
# Update Scoop and all buckets
scoop update

# Update a specific tool
scoop update cass

# Update all installed apps
scoop update *

# Force reinstall if having issues
scoop uninstall cass
scoop install dicklesworthstone/cass
```

## How Auto-Updates Work

This bucket uses multiple mechanisms to stay up-to-date:

### 1. Repository Dispatch (Fastest)
When a source repository publishes a new release, it can trigger an immediate manifest update via GitHub's `repository_dispatch` API.

### 2. Scheduled Checks (Every 6 hours)
A GitHub Actions workflow checks all source repositories for new releases and automatically updates manifests.

### 3. Manual Updates
Maintainers can manually trigger manifest updates via the GitHub Actions workflow_dispatch interface.

## Troubleshooting

### "Couldn't find manifest" error

```powershell
# Remove and re-add the bucket
scoop bucket rm dicklesworthstone
scoop bucket add dicklesworthstone https://github.com/Dicklesworthstone/scoop-bucket

# Force update
scoop update
```

### Hash mismatch error

This usually means a new release was published and the manifest hasn't been updated yet:

```powershell
# Update bucket information
scoop update

# If still failing, force install with skip
scoop install dicklesworthstone/cass -s
```

> **Note**: Using `-s` (skip hash check) should only be temporary. Report the issue if it persists.

### Check installed version

```powershell
# Show info about installed app
scoop info cass

# List all installed apps from this bucket
scoop list | Select-String dicklesworthstone
```

### App not in PATH

```powershell
# Scoop apps are installed to ~/scoop/apps/<app>/current/
# The shims should be in ~/scoop/shims/ which should be in PATH

# Check if shims directory is in PATH
$env:PATH -split ';' | Select-String scoop

# Reset shims if needed
scoop reset cass
```

### Uninstalling

```powershell
# Remove a specific tool
scoop uninstall cass

# Remove the bucket
scoop bucket rm dicklesworthstone
```

## For Maintainers

### Manual Manifest Update

To manually update a manifest when a new version is released:

```bash
cd /path/to/scoop-bucket
./scripts/update-manifest.sh <tool> <version>

# Examples:
./scripts/update-manifest.sh cass 0.1.56
./scripts/update-manifest.sh xf 0.2.1
./scripts/update-manifest.sh cm 0.2.4
```

The script will:
1. Fetch the new checksum from GitHub releases
2. Update the version, hash, and URL in the manifest
3. Show the git diff for review

### Manifest Structure

#### Architecture-Specific (cass, xf)

For tools that provide Windows-specific binaries:

```json
{
    "version": "1.0.0",
    "description": "Tool description",
    "homepage": "https://github.com/Dicklesworthstone/tool",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/.../releases/download/v1.0.0/tool-x86_64-pc-windows-msvc.zip",
            "hash": "sha256:abc123..."
        }
    },
    "bin": "tool.exe",
    "checkver": {
        "github": "https://github.com/Dicklesworthstone/tool"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/.../releases/download/v$version/tool-x86_64-pc-windows-msvc.zip"
            }
        }
    }
}
```

#### Simple (cm)

For tools with a single executable:

```json
{
    "version": "1.0.0",
    "description": "Tool description",
    "homepage": "https://github.com/Dicklesworthstone/tool",
    "license": "MIT",
    "url": "https://github.com/.../releases/download/v1.0.0/tool-windows-x64.exe#/tool.exe",
    "hash": "sha256:abc123...",
    "bin": "tool.exe",
    "checkver": {
        "github": "https://github.com/Dicklesworthstone/tool"
    },
    "autoupdate": {
        "url": "https://github.com/.../releases/download/v$version/tool-windows-x64.exe#/tool.exe"
    }
}
```

### Key Manifest Fields

| Field | Required | Description |
|-------|----------|-------------|
| `version` | Yes | Current version (without `v` prefix) |
| `description` | Yes | Brief description of the tool |
| `homepage` | Yes | URL to source repository |
| `license` | Recommended | License identifier (e.g., "MIT") |
| `url` or `architecture.64bit.url` | Yes | Download URL for the binary |
| `hash` or `architecture.64bit.hash` | Yes | SHA256 hash of the download |
| `bin` | Yes | Executable name(s) to add to PATH |
| `checkver` | Recommended | How Scoop checks for new versions |
| `autoupdate` | Recommended | URL pattern for automatic updates |

### URL Fragment for Renaming

Use `#/newname.exe` to rename downloaded files:

```json
"url": "https://github.com/.../cass-memory-windows-x64.exe#/cm.exe"
```

This downloads `cass-memory-windows-x64.exe` but installs it as `cm.exe`.

### CI Pipeline

Every push to manifest files triggers:

| Stage | Description |
|-------|-------------|
| **JSON Validation** | Syntax check, required field verification |
| **Install Test** | Full install/version/uninstall cycle on Windows |
| **Version Check** | Compares manifest versions against latest GitHub releases |

### Required Secrets for Auto-Updates

For source repositories to trigger automatic manifest updates via `repository_dispatch`, they need a Personal Access Token (PAT) with permission to trigger workflows on this repository.

#### Source Repository Secrets

| Secret Name | Purpose | Required Scope |
|-------------|---------|----------------|
| `SCOOP_BUCKET_TOKEN` | Trigger `manifest-update` event | `contents:write` on `Dicklesworthstone/scoop-bucket` |

#### Source Repositories

| Repository | Has Windows Build | Update Method |
|------------|-------------------|---------------|
| `coding_agent_session_search` (cass) | Yes | Auto-update workflow |
| `xf` | Yes | Auto-update workflow |
| `cass_memory_system` (cm) | Yes | Auto-update workflow |
| `destructive_command_guard` (dcg) | Yes | Auto-update workflow |
| `toon_rust` (tru) | Yes | Auto-update workflow |
| `beads_viewer` (bv) | Yes | GoReleaser |
| `coding_agent_account_manager` (caam) | Yes | GoReleaser |
| `slb` | Yes | GoReleaser |
| `ntm` | Yes | GoReleaser |

### Triggering Updates from Source Repos

Source repositories trigger automatic manifest updates by sending a `repository_dispatch` event:

```yaml
# In the source repo's release workflow
- name: Trigger Scoop bucket update
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.SCOOP_BUCKET_TOKEN }}
    repository: Dicklesworthstone/scoop-bucket
    event-type: manifest-update
    client-payload: |
      {
        "tool": "cass",
        "version": "${{ needs.release.outputs.version }}"
      }
```

## Directory Structure

```
scoop-bucket/
├── bv.json                # Beads Viewer (GoReleaser-managed)
├── caam.json              # Coding Agent Account Manager (GoReleaser-managed)
├── cass.json              # CASS manifest
├── cm.json                # CM manifest
├── dcg.json               # Destructive Command Guard
├── ntm.json               # Named Tmux Manager (GoReleaser-managed)
├── slb.json               # Simultaneous Launch Button (GoReleaser-managed)
├── tru.json               # TOON encoder/decoder
├── xf.json                # XF manifest
├── scripts/
│   └── update-manifest.sh # Update manifest version/hash
└── .github/workflows/
    ├── test-manifests.yml # CI: validate and install tests
    └── auto-update.yml    # Automatic manifest updates
```

## Comparison: Scoop vs Homebrew

| Feature | Scoop (Windows) | Homebrew (macOS/Linux) |
|---------|-----------------|------------------------|
| Package format | JSON manifests | Ruby formulas |
| Multi-arch | `architecture.64bit` | `on_intel`/`on_arm` blocks |
| Auto-update | `checkver` + `autoupdate` | Custom scripts/workflows |
| Install location | `~/scoop/apps/` | `/opt/homebrew/` or `/home/linuxbrew/` |
| PATH management | Shims in `~/scoop/shims/` | Symlinks in `bin/` |

## Related Resources

- **Homebrew Tap** (macOS/Linux): [Dicklesworthstone/homebrew-tap](https://github.com/Dicklesworthstone/homebrew-tap)
- **Source Repositories**: See individual tool links in the tables above

## License

Each tool has its own license. Check the individual repositories for details. This bucket repository itself is MIT licensed.

## Contributing

This bucket is primarily auto-maintained. For issues:

- **Tool bugs**: File issues in the respective tool's repository
- **Manifest bugs**: File issues in this repository
- **Feature requests**: File issues in the respective tool's repository

We don't accept external PRs for manifests as they are auto-generated, but issue reports are welcome.

## Prerequisites

### Installing Scoop

If you don't have Scoop installed:

```powershell
# Allow script execution (run as Administrator if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Scoop
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

### Recommended: Install Git

Scoop uses Git to manage buckets:

```powershell
scoop install git
```
