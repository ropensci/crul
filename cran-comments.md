## Test environments

* local OS X install, R 3.6.1 Patched
* ubuntu 14.04 (on travis-ci), R 3.6.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

* I have run R CMD check on the 61 downstream dependencies
(<https://github.com/ropensci/crul/blob/master/revdep/README.md>). No problems were found related to this package.

---

This version updates one of the vignettes, fixes a warning that was thrown when both httr and crul were loaded, fixes a bug with head verb, and adds new helpers for checking content types of HTTP responsees.

Thanks!
Scott Chamberlain
