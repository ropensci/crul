# codemetar

Version: 0.1.6

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘memoise’
      All declared Imports should be used.
    ```

# fauxpas

Version: 0.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘whisker’
      All declared Imports should be used.
    ```

# finch

Version: 0.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rappdirs’
      All declared Imports should be used.
    ```

# HIBPwned

Version: 0.1.7

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘memoise’ ‘ratelimitr’
      All declared Imports should be used.
    ```

# originr

Version: 0.3.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 2 marked UTF-8 strings
    ```

# rjsonapi

Version: 0.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘crul’
      All declared Imports should be used.
    ```

# rnoaa

Version: 0.8.0

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      > library(testthat)
      > test_check("rnoaa")
      Loading required package: rnoaa
      ── 1. Failure: arc2 fails with appropriate error messages (@test-arc2.R#11)  ───
      `arc2(date = "1978-01-01")` threw an error with unexpected message.
      Expected match: "must be between 1979 and 2018"
      Actual message: "dates[1] must be between 1979 and 2019"
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 94 SKIPPED: 50 FAILED: 1
      1. Failure: arc2 fails with appropriate error messages (@test-arc2.R#11) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# rsunlight

Version: 0.7.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘stringr’
      All declared Imports should be used.
    ```

# seaaroundus

Version: 1.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rgdal’
      All declared Imports should be used.
    ```

# vcr

Version: 0.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘crul’ ‘httr’
      All declared Imports should be used.
    ```

# worrms

Version: 0.3.0

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/test-all.R’ failed.
    Complete output:
      > library("testthat")
      > test_check("worrms")
      Loading required package: worrms
      Loading required namespace: jsonlite
      ── 1. Failure: wm_records_date - works (@test-wm_records_date.R#4)  ────────────
      all(grepl(format(Sys.Date(), "%Y"), aa$modified)) isn't true.
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 161 SKIPPED: 28 FAILED: 1
      1. Failure: wm_records_date - works (@test-wm_records_date.R#4) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

