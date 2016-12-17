crul 0.1.6
==========

### NEW FEATURES

* Improved options for using curl options. Can manually add
to list of curl options or pass in via `...`. And we 
check that user doesn't pass in prohibited options 
(`curl` package takes care of checking that options 
are valid) (#5)
* Incorporated `fauxpas` package for dealing with HTTP 
conditions. It's a Suggest, so only used if installed (#6)
* Added support for streaming via `curl::curl_fetch_stream`. 
`stream` param defaults to `NULL` (thus ignored), or pass in a 
function to use streaming. Only one of memory, streaming or 
disk allowed. (#9)
* Added support for streaming via `curl::curl_fetch_disk`. 
`disk` param defaults to `NULL` (thus ignored), or pass in a 
path to write to disk instead of use memory. Only one of memory, 
streaming or disk allowed. (#12)

### MINOR IMPROVEMENTS

* Added missing `raise_for_status()` method on the 
`HttpResponse` class (#10)

### BUG FIXES

* Was importing `httpcode` but wasn't using it in the package. 
Now using the package in `HttpResponse`


crul 0.1.0
==========

### NEW FEATURES

* Released to CRAN.
