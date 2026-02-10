# Recovery Procedures for Scoop Bucket

Procedures for diagnosing and recovering from bad manifest updates, broken installations, and release failures.

## Quick Reference

| Scenario | Action | Time to Fix |
|----------|--------|-------------|
| Bad manifest JSON | `git revert HEAD && git push` | < 2 min |
| Wrong checksum/URL | Update hash in manifest, push | < 5 min |
| Bad release binary | Pin to previous version | < 5 min |
| Complete bucket corruption | Reset to known-good commit | < 5 min |

## Procedure 1: Revert a Bad Manifest Commit

When a manifest update introduces JSON errors, wrong URLs, or bad hashes:

```bash
cd /data/projects/scoop-bucket

# 1. Identify the bad commit
git log --oneline -10

# 2. Revert
git revert HEAD  # If the latest commit is bad
# OR for a specific commit:
git revert <commit-sha>

# 3. Validate JSON syntax
for f in *.json; do jq empty "$f" && echo "OK: $f" || echo "BROKEN: $f"; done

# 4. Push the fix
git push origin main && git push origin main:master
```

## Procedure 2: Fix a Wrong Hash

When a release was re-tagged or the hash in the manifest doesn't match the actual binary:

```bash
# 1. Find the correct hash from the release
curl -sL "https://github.com/Dicklesworthstone/<repo>/releases/download/v<version>/<binary>.zip" | sha256sum

# 2. Update the manifest
# Edit <tool>.json - replace the "hash" value for the affected architecture

# 3. Validate
jq empty <tool>.json

# 4. Commit and push
git add <tool>.json
git commit -m "fix(<tool>): correct hash for v<version>"
git push origin main && git push origin main:master
```

## Procedure 3: Pin to a Known-Good Version

When the latest release has a critical bug:

```bash
# 1. Find the last known-good version
gh release list --repo Dicklesworthstone/<repo> --limit 5

# 2. Edit the manifest to use the older version
# In <tool>.json:
#   - Change "version" to the older version
#   - Update "url" to match
#   - Update "hash" to match
# NOTE: Scoop caches by version, so users will get the pinned version on next update

# 3. Validate and push
jq empty <tool>.json
git add <tool>.json
git commit -m "fix(<tool>): pin to vOLDER due to critical bug in vNEWER"
git push origin main && git push origin main:master
```

## Procedure 4: Emergency Deprecate a Manifest

When a tool must be taken offline immediately:

```json
{
    "version": "0.0.0",
    "description": "DEPRECATED: Critical issue discovered. See https://github.com/...",
    "homepage": "https://github.com/Dicklesworthstone/<repo>",
    "license": "MIT",
    "url": "",
    "hash": ""
}
```

To restore: revert the commit that deprecated it.

## Procedure 5: Reset Bucket to Known-Good State

```bash
cd /data/projects/scoop-bucket

# 1. Find the last known-good commit
git log --oneline -20

# 2. Revert range
git revert --no-commit <bad-commit-sha>..HEAD
git commit -m "revert: roll back to <good-sha> due to multiple bad updates"

# 3. Push
git push origin main && git push origin main:master
```

## Diagnosing User-Reported Issues

### "Hash check failed" Error

```bash
# Check what the manifest expects
jq '.hash // .architecture[].hash' <tool>.json

# Check the actual hash
curl -sL "<url-from-manifest>" | sha256sum
```

### "Download failed" or 404 Error

```bash
# Check if the release exists
gh release view v<version> --repo Dicklesworthstone/<repo>

# Check URL reachability
curl -sI "$(jq -r '.url // .architecture["64bit"].url' <tool>.json)" | head -5
```

### "Bucket not found"

```powershell
# Verify bucket is added
scoop bucket list
# Re-add if missing
scoop bucket add dicklesworthstone https://github.com/Dicklesworthstone/scoop-bucket
# Force update
scoop update
```

## Prevention Checklist

Before pushing any manifest change:

1. `jq empty <tool>.json` - JSON syntax check
2. Verify `url` is reachable
3. Verify `hash` matches the downloaded binary
4. Check `version` matches the release tag
5. Ensure `bin` path matches the actual binary name in the zip

## Monitoring

The `update-manifest.sh` script syncs manifests with upstream releases. If it produces bad updates:

```bash
# Check update script output
bash scripts/update-manifest.sh --dry-run <tool>

# If auto-update is running via GH Actions, disable temporarily
gh workflow disable <workflow>.yml --repo Dicklesworthstone/scoop-bucket
```

## Manifest Anatomy

```json
{
    "version": "0.1.55",
    "description": "Tool description",
    "homepage": "https://github.com/Dicklesworthstone/tool",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/.../releases/download/v0.1.55/tool-windows-amd64.zip",
            "hash": "abc123..."
        }
    },
    "bin": "tool.exe",
    "checkver": { "github": "https://github.com/Dicklesworthstone/tool" },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/.../releases/download/v$version/tool-windows-amd64.zip"
            }
        }
    }
}
```

## Post-Incident Template

After any recovery, document:

```
## Incident: <tool> v<version> - <date>
- **Detection**: How found (user report, CI, monitoring)
- **Impact**: Which platforms affected
- **Root Cause**: What went wrong
- **Resolution**: Fix applied
- **Prevention**: Changes to prevent recurrence
```
