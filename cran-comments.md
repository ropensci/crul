## Test environments

* local macOS install, R 4.5.1
* ubuntu 24.04 (on github actions), R 4.5.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

* I have run R CMD check on the downstream dependencies. Some problems were found testing against CRAN versions of packages, but should be fixed with this release in combination with the recently submitted webmockr and the upcoming vcr release.

---

This version deprecates a function, and adds it's functionality to other classes/functions in the package.

This and the upcoming vcr release are tied to the webmockr release in that they all are interconnected and need to be updated.

Thanks!
Scott Chamberlain
