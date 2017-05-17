## Test environments

* local OS X install, R 3.4.0
* ubuntu 12.04 (on travis-ci), R 3.4.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

  License components with restrictions and base license permitting such:
    MIT + file LICENSE
  File 'LICENSE':
    YEAR: 2017
    COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

* I have run R CMD check on the 20 downstream dependencies
(<https://github.com/ropensci/crul/blob/master/revdep/README.md>).
No problems were found. The two other maintainers were notified.

---

This version adds a few new functions, improves some HTTP headers
sent, and includes mocking integration.

Thanks!
Scott Chamberlain
