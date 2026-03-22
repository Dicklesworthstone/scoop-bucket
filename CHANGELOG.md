# Changelog

All notable changes to the **Dicklesworthstone Scoop Bucket** are documented here.

This repository has no tagged releases. Changes are tracked by commit. Manifest version bumps (auto-updates via GoReleaser or GitHub Actions) are grouped together; infrastructure and tooling changes are listed individually.

Repository: <https://github.com/Dicklesworthstone/scoop-bucket>

---

## 2026-03-15 — cass v0.2.2

### Manifest Updates

- **cass** bumped to v0.2.2 — [`a07f9e5`](https://github.com/Dicklesworthstone/scoop-bucket/commit/a07f9e536660cbc39e6417c8905ac6ed04af48a4)

---

## 2026-03-08 — 2026-03-09 — bv v0.15.0, ntm v1.8.0, cass v0.2.1

### Manifest Updates

- **cass** bumped to v0.2.1 — [`d5e0ba9`](https://github.com/Dicklesworthstone/scoop-bucket/commit/d5e0ba9b4cd0d26345fe733874f0b06f6030479e)
- **bv** bumped to v0.15.0 — [`5a28417`](https://github.com/Dicklesworthstone/scoop-bucket/commit/5a28417b6a9b42c1ce9943dc1fb14b742a8089bd)
- **ntm** bumped to v1.8.0 — [`8b2e9de`](https://github.com/Dicklesworthstone/scoop-bucket/commit/8b2e9de2328b69599649320704c1b806bc0e258a)

---

## 2026-03-02 — cass v0.2.0

### Manifest Updates

- **cass** bumped to v0.2.0 (major feature release) — [`bdd8436`](https://github.com/Dicklesworthstone/scoop-bucket/commit/bdd8436e5030c62758301770a9cf694e9d150edd)

---

## 2026-02-21 — 2026-02-23 — License update, tru v0.2.1

### Manifest Updates

- **tru** bumped to v0.2.1 — [`bb583de`](https://github.com/Dicklesworthstone/scoop-bucket/commit/bb583de419cb7a5dc0b8f73d6bb1093fd2363718)

### Repository Maintenance

- Update license to MIT with OpenAI/Anthropic Rider — [`c0829ed`](https://github.com/Dicklesworthstone/scoop-bucket/commit/c0829ed25160548af32e36ca84f2ee43edb50431)
- Update README license references to match new rider — [`0ecf0cc`](https://github.com/Dicklesworthstone/scoop-bucket/commit/0ecf0cc271513e86f7f03491ac301d678e79df49)
- Add GitHub social preview image (1280x640) — [`8edcbc4`](https://github.com/Dicklesworthstone/scoop-bucket/commit/8edcbc4c6a4ebec2b41cc8a991124601ead91875)

---

## 2026-02-15 — tru v0.2.0

### Manifest Updates

- **tru** bumped to v0.2.0 — [`062c9ef`](https://github.com/Dicklesworthstone/scoop-bucket/commit/062c9ef8ec91ac15760d634a9d54a7946b9a465e)

---

## 2026-02-10 — dcg v0.4.0

### Manifest Updates

- **dcg** bumped to v0.4.0 — [`1b1f566`](https://github.com/Dicklesworthstone/scoop-bucket/commit/1b1f5662cdadbde63c37d48a6fe0810012955a09)

---

## 2026-02-09 — Installation verification, dcg manifest, test expansion, PS 5.1 fixes

### New Manifests

- **dcg** (Destructive Command Guard) added at v0.3.0 — [`7ab8927`](https://github.com/Dicklesworthstone/scoop-bucket/commit/7ab89275953ab4d76d340ffe3522ec962266f785)

### CI / Infrastructure

- Add installation verification scripts: PowerShell for Windows install lifecycle testing, bash wrapper for manifest JSON validation and URL reachability, plus a GitHub Actions workflow for weekly verification — [`a35b4ee`](https://github.com/Dicklesworthstone/scoop-bucket/commit/a35b4ee15f70c99cce7e3f883dbec58d2453d350)
- Add dcg and tru to auto-update workflow matrix — [`8b405b1`](https://github.com/Dicklesworthstone/scoop-bucket/commit/8b405b16c5900e1f48c07817e08692747ce078b0)

### Bug Fixes

- Fix PS 5.1 compatibility: hashtable literal and empty array safety — [`7b06e71`](https://github.com/Dicklesworthstone/scoop-bucket/commit/7b06e716cfd1cede1cd8f8ef03247b1c6f752630)
- Fix PS 5.1 compatibility: if-expression assignment pattern — [`1178e7a`](https://github.com/Dicklesworthstone/scoop-bucket/commit/1178e7a90bf8bbf0092726dfc0667c9569bd9f35)
- Correct usage comment in verify-installation.ps1 — [`a623b2b`](https://github.com/Dicklesworthstone/scoop-bucket/commit/a623b2b28ff11d5265a583ae261d9b0006a9a0a8)

### Documentation

- Add rollback and recovery procedures (docs/RECOVERY.md): manifest revert, hash fixes, version pinning, emergency deprecation, bucket reset, user diagnosis, prevention checklist, post-incident template — [`239a053`](https://github.com/Dicklesworthstone/scoop-bucket/commit/239a053c093e34202b7a93629ec8a0131b4880b4)
- Update README: add all available tools, remove Coming Soon section — [`1b6318e`](https://github.com/Dicklesworthstone/scoop-bucket/commit/1b6318e4e79bc19d9e403f9b4e6c3cf9c12b052c)

### Manifest Maintenance

- Update tru.json asset URL, exe name, and description for tru-to-toon binary rename — [`06d5d26`](https://github.com/Dicklesworthstone/scoop-bucket/commit/06d5d261d5a99d0298dcb8f85b13c39f00744628)

---

## 2026-02-08 — Unit test framework

### CI / Infrastructure

- Add unit test framework: test-helpers.sh (assertion library with equals, contains, file_exists, json_field, etc.), test-runner.sh (suite filtering, structured JSON logging), and mock infrastructure for curl/git — [`b8603d2`](https://github.com/Dicklesworthstone/scoop-bucket/commit/b8603d2f11e4640816ef1617db0b70ec5d4fb19a)
- Add comprehensive unit tests for update-manifest.sh: 18 tests, 37 assertions covering all 3 tool paths (cass, xf, cm), version handling, architecture-specific and simple manifest updates, JSON validity, field preservation, idempotency, and error messages — [`be434c5`](https://github.com/Dicklesworthstone/scoop-bucket/commit/be434c53131731a3702c48d248c7ccc0689839df)

---

## 2026-02-05 — tru binary name fix, tru v0.1.2

### Bug Fixes

- Revert toon back to tru binary name in Scoop manifest (the binary ships as `tru`, not `toon`) — [`649a565`](https://github.com/Dicklesworthstone/scoop-bucket/commit/649a5656782051519103f21f3599a83702a48db4)
- Attempted tru-to-toon binary name rename (subsequently reverted) — [`1aab779`](https://github.com/Dicklesworthstone/scoop-bucket/commit/1aab7799963f1a0bf9650f2efd5007c19e40913c)

### Manifest Updates

- **tru** bumped to v0.1.2 — [`87fe883`](https://github.com/Dicklesworthstone/scoop-bucket/commit/87fe883077debe3657f86bfdc1702001c1ac287b)

---

## 2026-02-02 — cass v0.1.64, ntm v1.7.0, bv v0.14.1-v0.14.3

### Manifest Updates

- **bv** bumped to v0.14.3 — [`0cdefd9`](https://github.com/Dicklesworthstone/scoop-bucket/commit/0cdefd96575ed35cc0203d29e7fa0b728e200d22)
- **bv** bumped to v0.14.2 — [`2919f76`](https://github.com/Dicklesworthstone/scoop-bucket/commit/2919f7689fb2409e9cf9e2c641e3ec097a8bb543)
- **bv** bumped to v0.14.1 — [`4340383`](https://github.com/Dicklesworthstone/scoop-bucket/commit/4340383661f94df2c00728e1fa599ec0305f3408)
- **ntm** bumped to v1.7.0 — [`833cee2`](https://github.com/Dicklesworthstone/scoop-bucket/commit/833cee28d2b08c47eed74619eeb231378260512d)
- **cass** bumped to v0.1.64 — [`998b67a`](https://github.com/Dicklesworthstone/scoop-bucket/commit/998b67a224f2103b95babeaa27ccd457e3e9ec23)

---

## 2026-01-27 — cass v0.1.63

### Manifest Updates

- **cass** bumped to v0.1.63 — [`3a51233`](https://github.com/Dicklesworthstone/scoop-bucket/commit/3a51233c888482a953e0934e015eeb59ac86ee8a)

---

## 2026-01-24 — tru manifest added, cass v0.1.61, CI fix

### New Manifests

- **tru** (TOON encoder/decoder, toon_rust) added at v0.1.0 — [`655ec6c`](https://github.com/Dicklesworthstone/scoop-bucket/commit/655ec6c108b7df3fab02d130943b5b5b39d1a700)
  - Manifest updated shortly after initial add — [`248f872`](https://github.com/Dicklesworthstone/scoop-bucket/commit/248f8720efe93702313d9b192cb7b4d1201f514b)

### Manifest Updates

- **cass** bumped to v0.1.61 — [`dc8cd27`](https://github.com/Dicklesworthstone/scoop-bucket/commit/dc8cd2737b8221d9821c6dd6f8b15549baf578ab)

### Bug Fixes

- Fix auto-update workflow push failures: add explicit `contents: write` permission, concurrency group to prevent parallel runs, and retry logic with rebase for push race conditions — [`3fb7e79`](https://github.com/Dicklesworthstone/scoop-bucket/commit/3fb7e791ecf7b88dae6e64882500e51472875a4c)

---

## 2026-01-21 — caam v0.1.10, MIT license added

### Manifest Updates

- **caam** bumped to v0.1.10 — [`740e986`](https://github.com/Dicklesworthstone/scoop-bucket/commit/740e986bb00570ccb83ff17076036bdb19299e7f)

### Repository Maintenance

- Add MIT license — [`ac4a8b3`](https://github.com/Dicklesworthstone/scoop-bucket/commit/ac4a8b33a00d5ca39f151dcf54bf2a2a2a97f9c2)

---

## 2026-01-17 — Documentation update

### Documentation

- Update README documentation and configuration — [`5312660`](https://github.com/Dicklesworthstone/scoop-bucket/commit/531266071a0e46de1aa32b4da758b79854530ad5)

---

## 2026-01-15 — caam v0.1.4

### Manifest Updates

- **caam** bumped to v0.1.4 — [`4b4be22`](https://github.com/Dicklesworthstone/scoop-bucket/commit/4b4be22649f30bda4c0bf034f823abfc51234f80)

---

## 2026-01-14 — caam v0.1.3

### Manifest Updates

- **caam** bumped to v0.1.3 — [`593908a`](https://github.com/Dicklesworthstone/scoop-bucket/commit/593908a91201276d05c8f2d6ecb8a029a329f289)

---

## 2026-01-13 — Initial bucket infrastructure, cass/xf/cm/caam/slb/bv manifests

This is the foundational build-out of the Scoop bucket as a proper distribution channel for the Dicklesworthstone Stack on Windows.

### New Manifests

- **cass** (Coding Agent Session Search) added at v0.1.55 — [`dcfe55f`](https://github.com/Dicklesworthstone/scoop-bucket/commit/dcfe55f94b29b5ac517b84599845f65c78aaa69f)
- **xf** (X-Former / Twitter Archive Search) added at v0.2.0 — [`dcfe55f`](https://github.com/Dicklesworthstone/scoop-bucket/commit/dcfe55f94b29b5ac517b84599845f65c78aaa69f)
- **cm** (CASS Memory System) added at v0.2.3 — [`51c6d80`](https://github.com/Dicklesworthstone/scoop-bucket/commit/51c6d808694410cf3c81071612475a18bf3b60a2)
- **caam** (Coding Agent Account Manager) first seen at v0.1.2 via GoReleaser — [`5f96767`](https://github.com/Dicklesworthstone/scoop-bucket/commit/5f96767f21f58e1b5d5c6a6311b230018b663aff)
- **slb** (Simultaneous Launch Button) first seen at v0.2.0 via GoReleaser — [`ee535ff`](https://github.com/Dicklesworthstone/scoop-bucket/commit/ee535ff05bfdb81cbf6b306c4630524d8cf1fce9)
- **bv** (Beads Viewer) first seen at v0.13.0 via GoReleaser — [`af9c0f9`](https://github.com/Dicklesworthstone/scoop-bucket/commit/af9c0f9e81de0a814f70bb760a5d2740cfdc5539)

### CI / Infrastructure

- Add CI test workflow (test-manifests.yml): JSON validation, required field checks, full install/version/uninstall test on Windows, version update checking against GitHub releases, log artifact upload — [`278b824`](https://github.com/Dicklesworthstone/scoop-bucket/commit/278b824f73234f7ed6668c629456670329eda376)
- Add weekly scheduled tests and platform summaries — [`a32da14`](https://github.com/Dicklesworthstone/scoop-bucket/commit/a32da147ad2ff7a4134f008feb3fa111f4c53a7d)
- Add auto-update workflow (auto-update.yml): repository_dispatch listener, manual workflow_dispatch, scheduled 6-hour fallback check, matrix job for all Scoop-compatible tools — [`68e7995`](https://github.com/Dicklesworthstone/scoop-bucket/commit/68e7995082f86d561884b55894166f339a7a0b02)
- Add update-manifest.sh script for manual manifest version/hash updates — [`68e7995`](https://github.com/Dicklesworthstone/scoop-bucket/commit/68e7995082f86d561884b55894166f339a7a0b02)

### Bug Fixes

- Fix auto-update workflow: add URL update step — [`3602ebd`](https://github.com/Dicklesworthstone/scoop-bucket/commit/3602ebdb1ca1fba9f624895e34d228bc7e448fc6)
- Fix update-manifest.sh: prevent spurious hash field in architecture-specific manifests — [`9c621e2`](https://github.com/Dicklesworthstone/scoop-bucket/commit/9c621e27bdc9bc332103dd58d1abd7c5e88fa418)

### Documentation

- Add comprehensive README with installation instructions, tool listing, troubleshooting guide, CI pipeline overview, manifest structure documentation, and maintainer guide — [`2f51d46`](https://github.com/Dicklesworthstone/scoop-bucket/commit/2f51d46c66ed489865427d84420599900a79a047)

---

## 2025-12-14 — 2026-01-06 — Initial commits (ntm via GoReleaser)

The repository was bootstrapped by GoReleaser with the ntm manifest. These are the earliest commits.

### New Manifests

- **ntm** (Named Tmux Manager) added at v1.2.0 — [`8397f9a`](https://github.com/Dicklesworthstone/scoop-bucket/commit/8397f9ae33c4a659d5b3241f4b79a576eeb7fae5) *(first commit in repo, 2025-12-14)*

### Manifest Updates

- **ntm** bumped to v1.5.0 — [`ff72380`](https://github.com/Dicklesworthstone/scoop-bucket/commit/ff723802aea6f0552c481f6987cc4f6d55cdadba)
- **ntm** bumped to v1.4.1 — [`f099f43`](https://github.com/Dicklesworthstone/scoop-bucket/commit/f099f432ecbead948d6be83f79ca9136ec5ec0a1)
- **ntm** bumped to v1.4.0 — [`efa9624`](https://github.com/Dicklesworthstone/scoop-bucket/commit/efa96240bdbcf44aa5849baa4e651e466421de8a)
- **ntm** bumped to v1.3.0 — [`2846358`](https://github.com/Dicklesworthstone/scoop-bucket/commit/2846358750f85f147d6fd7c52030bb1e93fc9206)

---

## Manifest Version Summary

Current manifest versions as of 2026-03-15:

| Manifest | Tool | Current Version | First Added | Update Method |
|----------|------|-----------------|-------------|---------------|
| `cass.json` | Coding Agent Session Search | 0.2.2 | 2026-01-13 | GitHub Actions auto-update |
| `xf.json` | X-Former (Twitter Archive Search) | 0.2.0 | 2026-01-13 | GitHub Actions auto-update |
| `cm.json` | CASS Memory System | 0.2.3 | 2026-01-13 | GitHub Actions auto-update |
| `dcg.json` | Destructive Command Guard | 0.4.0 | 2026-02-09 | GitHub Actions auto-update |
| `tru.json` | TOON encoder/decoder | 0.2.1 | 2026-01-24 | GitHub Actions auto-update |
| `bv.json` | Beads Viewer | 0.15.0 | 2026-01-13 | GoReleaser |
| `caam.json` | Coding Agent Account Manager | 0.1.10 | 2026-01-13 | GoReleaser |
| `slb.json` | Simultaneous Launch Button | 0.2.0 | 2026-01-13 | GoReleaser |
| `ntm.json` | Named Tmux Manager | 1.8.0 | 2025-12-14 | GoReleaser |

## Infrastructure Timeline

| Date | Capability | Commit |
|------|-----------|--------|
| 2025-12-14 | Repository created (ntm manifest via GoReleaser) | [`8397f9a`](https://github.com/Dicklesworthstone/scoop-bucket/commit/8397f9ae33c4a659d5b3241f4b79a576eeb7fae5) |
| 2026-01-13 | CI test workflow (test-manifests.yml) | [`278b824`](https://github.com/Dicklesworthstone/scoop-bucket/commit/278b824f73234f7ed6668c629456670329eda376) |
| 2026-01-13 | Auto-update workflow + update-manifest.sh | [`68e7995`](https://github.com/Dicklesworthstone/scoop-bucket/commit/68e7995082f86d561884b55894166f339a7a0b02) |
| 2026-01-21 | MIT license added | [`ac4a8b3`](https://github.com/Dicklesworthstone/scoop-bucket/commit/ac4a8b33a00d5ca39f151dcf54bf2a2a2a97f9c2) |
| 2026-01-24 | CI fix: push permissions, concurrency, retry | [`3fb7e79`](https://github.com/Dicklesworthstone/scoop-bucket/commit/3fb7e791ecf7b88dae6e64882500e51472875a4c) |
| 2026-02-08 | Unit test framework (test-helpers.sh, test-runner.sh) | [`b8603d2`](https://github.com/Dicklesworthstone/scoop-bucket/commit/b8603d2f11e4640816ef1617db0b70ec5d4fb19a) |
| 2026-02-08 | Comprehensive update-manifest.sh tests (18 tests, 37 assertions) | [`be434c5`](https://github.com/Dicklesworthstone/scoop-bucket/commit/be434c53131731a3702c48d248c7ccc0689839df) |
| 2026-02-09 | Installation verification scripts + workflow | [`a35b4ee`](https://github.com/Dicklesworthstone/scoop-bucket/commit/a35b4ee15f70c99cce7e3f883dbec58d2453d350) |
| 2026-02-09 | Recovery/rollback documentation (docs/RECOVERY.md) | [`239a053`](https://github.com/Dicklesworthstone/scoop-bucket/commit/239a053c093e34202b7a93629ec8a0131b4880b4) |
| 2026-02-21 | License updated to MIT with OpenAI/Anthropic Rider | [`c0829ed`](https://github.com/Dicklesworthstone/scoop-bucket/commit/c0829ed25160548af32e36ca84f2ee43edb50431) |
