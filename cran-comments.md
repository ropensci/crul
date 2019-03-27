## Test environments

* local OS X install, R 3.5.3
* ubuntu 14.04 (on travis-ci), R 3.5.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

  License components with restrictions and base license permitting such:
    MIT + file LICENSE
  File 'LICENSE':
    YEAR: 2019
    COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

* I have run R CMD check on the 60 downstream dependencies
(includes some archived packageS; <https://github.com/ropensci/crul/blob/master/revdep/README.md>). No problems were found related to this package.

---

This version adds major functionality to the main http request object HttpClient for setting request and response hooks for user supplied functions. In addition, improves behavior for the parsing method for request responses, and adds a progress bar to a method.

Thanks!
Scott Chamberlain
