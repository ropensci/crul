## Test environments

* local OS X install, R 3.3.2
* ubuntu 12.04 (on travis-ci), R 3.3.2
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

  License components with restrictions and base license permitting such:
    MIT + file LICENSE
  File 'LICENSE':
    YEAR: 2016
    COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

* I have run R CMD check on the 2 downstream dependencies
(<https://github.com/ropensci/crul/blob/master/revdep/README.md>).
No problems were found. The maintainers are me.

---

This version adds a missing method on the `HttpResponse` class, and 
adds new options for writing to disk and streaming responses. In 
addition, improved curl option passing, and using `fauxpas` package
now for HTTP condition handling.

Thanks!
Scott Chamberlain
