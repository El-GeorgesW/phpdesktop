# Platform source import

This branch uses isolated snapshots of the upstream platform branches:

- `platform/windows`: upstream `chrome130`
- `platform/macos`: upstream `mac130`
- `platform/linux`: upstream `linux70`

Import them with:

```sh
./scripts/import-upstream-sources.sh
./scripts/verify-platform-sources.sh
```

The script pins the exact fetched commit in its output. Commit that value in
`UPSTREAM_SOURCES.md` after reviewing the imported tree.

## Why the sources are not vendored here yet

The upstream Windows tree contains the CEF SDK and the platform trees contain
large generated/vendor assets. The GitHub file API available for this task can
write individual files, but cannot copy an entire cross-repository Git tree in
one operation. The import script performs the complete, auditable Git import
locally without silently truncating the SDK.

These are source baselines, not current dependency versions. Before producing
releases, update each platform's CEF/Chromium and PHP download pins, verify
SHA-256 checksums, rebuild PHP with the required extensions, and run the
platform smoke tests. Do not commit downloaded binaries or secrets.
