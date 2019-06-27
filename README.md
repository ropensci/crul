crul
====



[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/ropensci/crul.svg?branch=master)](https://travis-ci.org/ropensci/crul)
[![codecov](https://codecov.io/gh/ropensci/crul/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/crul)
[![cran checks](https://cranchecks.info/badges/worst/crul)](https://cranchecks.info/pkgs/crul)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/crul)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/crul)](https://cran.r-project.org/package=crul)

An HTTP client, taking inspiration from Ruby's [faraday](https://rubygems.org/gems/faraday) and Python's [requests](http://docs.python-requests.org/en/master/)

Package API:

* `HttpClient` - Main interface to making HTTP requests. Synchronous requests only.
* `HttpResponse` - HTTP response object, used for all responses across the
different clients.
* `Paginator` - Auto-paginate through requests - supports a subset of all possible
pagination scenarios - will fill out more scenarios soon
* `Async` - Asynchronous HTTP requests - a simple interface for many URLS -
whose interface is similar to `HttpClient` - all URLs are treated the same.
* `AsyncVaried` - Asynchronous HTTP requests - accepts any number of `HttpRequest`
objects - with a different interface than `HttpClient`/`Async` due to the nature
of handling requests with different HTTP methods, options, etc.
* `HttpRequest` - HTTP request object, used for `AsyncVaried`
* `mock()` - Turn on/off mocking, via `webmockr`
* `auth()` - Simple authentication helper
* `proxy()` - Proxy helper
* `upload()` - File upload helper
* set curl options globally: `set_auth()`, `set_headers()`, `set_opts()`, `set_proxy()`, and `crul_settings()`
* Writing to disk and streaming: available with both synchronous requests
as well as async requests
* Hooks on requests and responses are available in the `HttpClient` method only, 
and allow you to trigger functions to run on requests or responses, or both.
See `?hooks` for the details and examples

Mocking:

`crul` now integrates with [webmockr](https://github.com/ropensci/webmockr) to mock
HTTP requests. Checkout the [http testing book](https://ropenscilabs.github.io/http-testing-book/)

Caching:

`crul` also integrates with [vcr](https://github.com/ropensci/vcr) to cache http requests/responses. Checkout the [http testing book](https://ropenscilabs.github.io/http-testing-book/)

## Installation

CRAN version


```r
install.packages("crul")
```

Dev version


```r
devtools::install_github("ropensci/crul")
```


```r
library("crul")
```

## the client

`HttpClient` is where to start


```r
(x <- HttpClient$new(
  url = "https://httpbin.org",
  opts = list(
    timeout = 1
  ),
  headers = list(
    a = "hello world"
  )
))
#> <crul connection> 
#>   url: https://httpbin.org
#>   curl options: 
#>     timeout: 1
#>   proxies: 
#>   auth: 
#>   headers: 
#>     a: hello world
#>   progress: FALSE
#>   hooks:
```

Makes an R6 class, that has all the bits and bobs you'd expect for doing HTTP
requests. When it prints, it gives any defaults you've set. As you update
the object you can see what's been set


```r
x$opts
#> $timeout
#> [1] 1
```


```r
x$headers
#> $a
#> [1] "hello world"
```

You can also pass in curl options when you make HTTP requests, see below
for examples.

## do some http

The client object created above has http methods that you can call,
and pass paths to, as well as query parameters, body values, and any other
curl options.

Here, we'll do a __GET__ request on the route `/get` on our base url
`https://httpbin.org` (the full url is then `https://httpbin.org/get`)


```r
res <- x$get("get")
```

The response from a http request is another R6 class `HttpResponse`, which
has slots for the outputs of the request, and some functions to deal with
the response:

Status code


```r
res$status_code
#> [1] 200
```

Status information


```r
res$status_http()
#> <Status code: 200>
#>   Message: OK
#>   Explanation: Request fulfilled, document follows
```

The content


```r
res$content
#>   [1] 7b 0a 20 20 22 61 72 67 73 22 3a 20 7b 7d 2c 20 0a 20 20 22 68 65 61
#>  [24] 64 65 72 73 22 3a 20 7b 0a 20 20 20 20 22 41 22 3a 20 22 68 65 6c 6c
#>  [47] 6f 20 77 6f 72 6c 64 22 2c 20 0a 20 20 20 20 22 41 63 63 65 70 74 22
#>  [70] 3a 20 22 61 70 70 6c 69 63 61 74 69 6f 6e 2f 6a 73 6f 6e 2c 20 74 65
#>  [93] 78 74 2f 78 6d 6c 2c 20 61 70 70 6c 69 63 61 74 69 6f 6e 2f 78 6d 6c
#> [116] 2c 20 2a 2f 2a 22 2c 20 0a 20 20 20 20 22 41 63 63 65 70 74 2d 45 6e
#> [139] 63 6f 64 69 6e 67 22 3a 20 22 67 7a 69 70 2c 20 64 65 66 6c 61 74 65
#> [162] 22 2c 20 0a 20 20 20 20 22 48 6f 73 74 22 3a 20 22 68 74 74 70 62 69
#> [185] 6e 2e 6f 72 67 22 2c 20 0a 20 20 20 20 22 55 73 65 72 2d 41 67 65 6e
#> [208] 74 22 3a 20 22 6c 69 62 63 75 72 6c 2f 37 2e 35 34 2e 30 20 72 2d 63
#> [231] 75 72 6c 2f 33 2e 33 20 63 72 75 6c 2f 30 2e 37 2e 34 2e 39 33 31 30
#> [254] 22 0a 20 20 7d 2c 20 0a 20 20 22 6f 72 69 67 69 6e 22 3a 20 22 36 35
#> [277] 2e 31 39 37 2e 31 34 36 2e 31 38 2c 20 36 35 2e 31 39 37 2e 31 34 36
#> [300] 2e 31 38 22 2c 20 0a 20 20 22 75 72 6c 22 3a 20 22 68 74 74 70 73 3a
#> [323] 2f 2f 68 74 74 70 62 69 6e 2e 6f 72 67 2f 67 65 74 22 0a 7d 0a
```

HTTP method


```r
res$method
#> [1] "get"
```

Request headers


```r
res$request_headers
#> $`User-Agent`
#> [1] "libcurl/7.54.0 r-curl/3.3 crul/0.7.4.9310"
#> 
#> $`Accept-Encoding`
#> [1] "gzip, deflate"
#> 
#> $Accept
#> [1] "application/json, text/xml, application/xml, */*"
#> 
#> $a
#> [1] "hello world"
```

Response headers


```r
res$response_headers
#> $status
#> [1] "HTTP/1.1 200 OK"
#> 
#> $`access-control-allow-credentials`
#> [1] "true"
#> 
#> $`access-control-allow-origin`
#> [1] "*"
#> 
#> $`content-encoding`
#> [1] "gzip"
#> 
#> $`content-type`
#> [1] "application/json"
#> 
#> $date
#> [1] "Thu, 13 Jun 2019 17:57:47 GMT"
#> 
#> $`referrer-policy`
#> [1] "no-referrer-when-downgrade"
#> 
#> $server
#> [1] "nginx"
#> 
#> $`x-content-type-options`
#> [1] "nosniff"
#> 
#> $`x-frame-options`
#> [1] "DENY"
#> 
#> $`x-xss-protection`
#> [1] "1; mode=block"
#> 
#> $`content-length`
#> [1] "232"
#> 
#> $connection
#> [1] "keep-alive"
```

All response headers - e.g., intermediate headers


```r
res$response_headers_all
```

And you can parse the content with `parse()`


```r
res$parse()
#> No encoding supplied: defaulting to UTF-8.
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"A\": \"hello world\", \n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.3 crul/0.7.4.9310\"\n  }, \n  \"origin\": \"65.197.146.18, 65.197.146.18\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"
jsonlite::fromJSON(res$parse())
#> No encoding supplied: defaulting to UTF-8.
#> $args
#> named list()
#> 
#> $headers
#> $headers$A
#> [1] "hello world"
#> 
#> $headers$Accept
#> [1] "application/json, text/xml, application/xml, */*"
#> 
#> $headers$`Accept-Encoding`
#> [1] "gzip, deflate"
#> 
#> $headers$Host
#> [1] "httpbin.org"
#> 
#> $headers$`User-Agent`
#> [1] "libcurl/7.54.0 r-curl/3.3 crul/0.7.4.9310"
#> 
#> 
#> $origin
#> [1] "65.197.146.18, 65.197.146.18"
#> 
#> $url
#> [1] "https://httpbin.org/get"
```

## curl options


```r
res <- HttpClient$new(url = "http://api.gbif.org/v1/occurrence/search")
res$get(query = list(limit = 100), timeout_ms = 100)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) :
#>   Timeout was reached
```

## Asynchronous requests

The simpler interface allows many requests (many URLs), but they all get the same
options/headers, etc. and you have to use the same HTTP method on all of them:


```r
(cc <- Async$new(
  urls = c(
    'https://httpbin.org/',
    'https://httpbin.org/get?a=5',
    'https://httpbin.org/get?foo=bar'
  )
))
res <- cc$get()
lapply(res, function(z) z$parse("UTF-8"))
```

The `AsyncVaried` interface accepts any number of `HttpRequest` objects, which
can define any type of HTTP request of any HTTP method:


```r
req1 <- HttpRequest$new(
  url = "https://httpbin.org/get",
  opts = list(verbose = TRUE),
  headers = list(foo = "bar")
)$get()
req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post()
out <- AsyncVaried$new(req1, req2)
```

Execute the requests


```r
out$request()
```

Then functions get applied to all responses:


```r
out$status()
#> [[1]]
#> <Status code: 200>
#>   Message: OK
#>   Explanation: Request fulfilled, document follows
#> 
#> [[2]]
#> <Status code: 200>
#>   Message: OK
#>   Explanation: Request fulfilled, document follows
out$parse()
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Foo\": \"bar\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"R (3.6.0 x86_64-apple-darwin15.6.0 x86_64 darwin15.6.0)\"\n  }, \n  \"origin\": \"65.197.146.18, 65.197.146.18\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"                                                                                                                                        
#> [2] "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Content-Length\": \"0\", \n    \"Content-Type\": \"application/x-www-form-urlencoded\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.3 crul/0.7.4.9310\"\n  }, \n  \"json\": null, \n  \"origin\": \"65.197.146.18, 65.197.146.18\", \n  \"url\": \"https://httpbin.org/post\"\n}\n"
```

## Progress bars


```r
library(httr)
x <- HttpClient$new(
  url = "https://httpbin.org/bytes/102400", 
  progress = progress()
)
z <- x$get()
|==============================================| 100%
```


## TO DO

* ...

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/crul/issues).
* License: MIT
* Get citation information for `crul` in R doing `citation(package = 'crul')`
* Please note that this project is released with a [Contributor Code of Conduct][coc].
By participating in this project you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)

[coc]: https://github.com/ropensci/crul/blob/master/CODE_OF_CONDUCT.md
