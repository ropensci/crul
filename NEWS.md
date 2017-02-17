crul 0.3.0
==========

### NEW FEATURES

* Added support for asynchronous HTTP requests, including two new
R6 classes: `Async` and `AsyncVaried`. The former being a simpler 
interface treating all URLs with same options/HTTP method, and the latter 
allowing any type of request through the new R6 class `HttpRequest` (#8) (#24)
* New R6 class `HttpRequest` to support `AsyncVaried` - this method
only defines a request, but does not execute it. (#8)

### MINOR IMPROVEMENTS

* Added support for proxies (#22)

### BUG FIXES

* Fixed parsing of headers from FTP servers (#21)


crul 0.2.0
==========

### MINOR IMPROVEMENTS

* Created new manual files for various tasks to document
usage better (#19)
* URL encode paths - should fix any bugs where spaces between words
caused errors previously (#17)
* URL encode query parameters - should fix any bugs where spaces between words
caused errors previously (#11)
* request headers now passed correctly to response object (#13)
* response headers now parsed to a list for easier access (#14)
* Now supporting multiple query parameters of the same name, wasn't
possible in last version (#15)


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
