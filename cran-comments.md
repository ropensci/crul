## Test environments

* local macOS install, R 4.0.3 Patched
* ubuntu 16.04 (on github actions), R 4.0.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

* I have run R CMD check on the 73 downstream dependencies
(<https://github.com/ropensci/crul/blob/master/revdep/README.md>). No problems were found related to this package. A few packages failed during reverse dependency checks but when checked individually they had no problems (revdepcheck probably just failed on installation).

---

This version includes a fix for handling of numbers, handling of http response headers, and adds a new feature to an existing function.

Thanks!
Scott Chamberlain
