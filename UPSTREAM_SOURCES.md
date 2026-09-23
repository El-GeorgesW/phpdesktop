# Upstream source import plan

This branch is intended to host an independent multi-platform update of PHP Desktop.

## Upstream baselines inspected

| Platform | Upstream branch | Upstream commit | Current upstream baseline |
| --- | --- | --- | --- |
| Windows | `chrome130` | `c279c42f968a233e7cdc153d7e6a3aeff8b8a7bb` | Chromium/CEF 130.1, PHP 8.3 |
| macOS | `mac130` | `d9d485fa8b27adfbe2a25a8385823a829a2b581b` | Chromium/CEF 130.3, PHP 8.4.x build scripts |
| Linux | `linux70` | `c3cd347dff9c4d9623fc46d1312c393ce6f539a3` | Chromium 72.1, PHP 7.2.12 |

## Important limitation

The GitHub API operations available to this workspace can create branches and commit explicitly supplied files, but cannot perform a cross-repository merge or copy an entire Git tree. The upstream branches also contain large generated CEF SDK trees and platform binaries that cannot be reconstructed by copying only the visible file listing.

Consequently, this file records the exact immutable import baselines, but does not claim that the complete upstream trees have been imported. A local Git operation is required for a complete import, for example:

```sh
git remote add upstream https://github.com/cztomczak/phpdesktop.git
git fetch --no-tags upstream chrome130 mac130 linux70
git read-tree --prefix=platform/windows/ upstream/chrome130
git read-tree --prefix=platform/macos/ upstream/mac130
git read-tree --prefix=platform/linux/ upstream/linux70
git commit -m "Import upstream platform sources"
```

The three trees must then be reconciled into a common release layout before building releases. The imported baselines are not the latest Chromium/PHP versions: Windows and macOS are Chromium 130-era, while Linux remains Chromium 72/PHP 7.2. A separate dependency-upgrade phase is required to reach current stable versions.
