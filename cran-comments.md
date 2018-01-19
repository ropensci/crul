## Test environments

* local OS X install, R 3.4.3 patched
* ubuntu 12.04 (on travis-ci), R 3.4.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

  License components with restrictions and base license permitting such:
    MIT + file LICENSE
  File 'LICENSE':
    YEAR: 2018
    COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

* I have run R CMD check on the 40 downstream dependencies
(<https://github.com/ropensci/crul/blob/master/revdep/README.md>).
No problems were found. The two other maintainers were notified.

---

This version includes a new R6 class for paginating requests, includes new support for writing to disk and streaming data for asynchronous requests, and some minor improvements.

Thanks!
Scott Chamberlain
