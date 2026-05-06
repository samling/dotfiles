## Bump a package version

* Set `pkgver` in `PKGBUILD` to new package version
* Reset `pkgrel` to `1`
* Run `updpkgsums` to download the package(s) and calcuate the shasums for `@./<package>/PKGBUILD`
* Install the latest: `paru -S <package>`
