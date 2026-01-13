# Dicklesworthstone Scoop Bucket

Scoop manifests for the Dicklesworthstone Stack - a collection of tools for AI coding agents and developer productivity on Windows.

## Installation

First, add this bucket to your Scoop:

```powershell
scoop bucket add dicklesworthstone https://github.com/Dicklesworthstone/scoop-bucket
```

Then install any tool:

```powershell
scoop install dicklesworthstone/<tool-name>
```

## Available Packages

| Package | Description | Install |
|---------|-------------|---------|
| **ntm** | Named Tmux Manager - Orchestrate AI coding agents in tmux sessions | `scoop install dicklesworthstone/ntm` |
| **bv** | Beads Viewer - Graph-aware task management TUI | `scoop install dicklesworthstone/bv` |
| **caam** | Coding Agent Account Manager - Switch between AI agent accounts | `scoop install dicklesworthstone/caam` |
| **slb** | Simultaneous Launch Button - Two-person rule for dangerous commands | `scoop install dicklesworthstone/slb` |
| **cass** | Coding Agent Session Search - Unified agent history search | `scoop install dicklesworthstone/cass` |
| **xf** | X/Twitter data search tool | `scoop install dicklesworthstone/xf` |
| **cm** | Cass Memory System - Procedural memory for AI agents | `scoop install dicklesworthstone/cm` |

> **Note**: Some tools (ru, ubs) are Bash-based and not available on Windows.

## Package Status

| Package | Status | Auto-Update |
|---------|--------|-------------|
| ntm | Available | GoReleaser |
| bv | Coming Soon | GoReleaser |
| caam | Coming Soon | GoReleaser |
| slb | Coming Soon | GoReleaser |
| cass | Coming Soon | Manual |
| xf | Coming Soon | Manual |
| cm | Coming Soon | Manual |

## Updating

To update a specific package:

```powershell
scoop update dicklesworthstone/<tool-name>
```

Or update everything:

```powershell
scoop update *
```

## Troubleshooting

### Bucket not found

If adding the bucket fails:

```powershell
# Remove and re-add
scoop bucket rm dicklesworthstone
scoop bucket add dicklesworthstone https://github.com/Dicklesworthstone/scoop-bucket
```

### Hash mismatch

This usually means a new release was published:

```powershell
scoop update
scoop install dicklesworthstone/<tool-name> --force
```

### Check installed version

```powershell
scoop info dicklesworthstone/<tool-name>
```

## Development & Testing

### CI Pipeline

Every push to manifest files triggers:

1. **JSON Validation**: Syntax and required field checks
2. **Install Test**: Full install/version/uninstall cycle on Windows
3. **Version Check**: Alerts when newer versions are available

### Manifest Structure

Each manifest (`<tool>.json`) contains:

```json
{
    "version": "1.0.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/.../releases/download/v1.0.0/tool_windows_amd64.zip",
            "hash": "sha256:...",
            "bin": ["tool.exe"]
        }
    },
    "homepage": "https://github.com/Dicklesworthstone/tool",
    "license": "MIT",
    "description": "Tool description"
}
```

## Related Projects

- [ntm](https://github.com/Dicklesworthstone/ntm) - Named Tmux Manager
- [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) - Task management TUI
- [coding_agent_account_manager](https://github.com/Dicklesworthstone/coding_agent_account_manager) - Agent account switching
- [simultaneous_launch_button](https://github.com/Dicklesworthstone/simultaneous_launch_button) - Two-person rule
- [coding_agent_session_search](https://github.com/Dicklesworthstone/coding_agent_session_search) - Session search
- [cass_memory_system](https://github.com/Dicklesworthstone/cass_memory_system) - Agent memory

## License

Each tool has its own license. Check the individual repositories for details.

## Contributing

This bucket is auto-generated and maintained. For issues with specific tools, please file issues in their respective repositories.
