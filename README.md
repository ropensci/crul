crul
====



[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/ropensci/crul.svg?branch=master)](https://travis-ci.org/ropensci/crul)
[![codecov](https://codecov.io/gh/ropensci/crul/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/crul)
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
* Writing to disk and streaming: available with both synchronous requests
as well as async requests.

Mocking:

`crul` now integrates with [webmockr](https://github.com/ropensci/webmockr) to mock
HTTP requests. Integration with [vcr](https://github.com/ropensci/vcr) to mock specifically
around tests is coming soon.

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
```

Makes a R6 class, that has all the bits and bobs you'd expect for doing HTTP
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
#> [162] 22 2c 20 0a 20 20 20 20 22 43 6f 6e 6e 65 63 74 69 6f 6e 22 3a 20 22
#> [185] 63 6c 6f 73 65 22 2c 20 0a 20 20 20 20 22 48 6f 73 74 22 3a 20 22 68
#> [208] 74 74 70 62 69 6e 2e 6f 72 67 22 2c 20 0a 20 20 20 20 22 55 73 65 72
#> [231] 2d 41 67 65 6e 74 22 3a 20 22 6c 69 62 63 75 72 6c 2f 37 2e 35 34 2e
#> [254] 30 20 72 2d 63 75 72 6c 2f 33 2e 31 20 63 72 75 6c 2f 30 2e 35 2e 30
#> [277] 22 0a 20 20 7d 2c 20 0a 20 20 22 6f 72 69 67 69 6e 22 3a 20 22 35 30
#> [300] 2e 32 32 2e 31 35 35 2e 32 31 34 22 2c 20 0a 20 20 22 75 72 6c 22 3a
#> [323] 20 22 68 74 74 70 73 3a 2f 2f 68 74 74 70 62 69 6e 2e 6f 72 67 2f 67
#> [346] 65 74 22 0a 7d 0a
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
#> [1] "libcurl/7.54.0 r-curl/3.1 crul/0.5.0"
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
#> $connection
#> [1] "keep-alive"
#> 
#> $server
#> [1] "meinheld/0.6.1"
#> 
#> $date
#> [1] "Fri, 19 Jan 2018 18:42:29 GMT"
#> 
#> $`content-type`
#> [1] "application/json"
#> 
#> $`access-control-allow-origin`
#> [1] "*"
#> 
#> $`access-control-allow-credentials`
#> [1] "true"
#> 
#> $`x-powered-by`
#> [1] "Flask"
#> 
#> $`x-processed-time`
#> [1] "0.000702142715454"
#> 
#> $`content-length`
#> [1] "351"
#> 
#> $via
#> [1] "1.1 vegur"
```

And you can parse the content with `parse()`


```r
res$parse()
#> No encoding supplied: defaulting to UTF-8.
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"A\": \"hello world\", \n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"
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
#> $headers$Connection
#> [1] "close"
#> 
#> $headers$Host
#> [1] "httpbin.org"
#> 
#> $headers$`User-Agent`
#> [1] "libcurl/7.54.0 r-curl/3.1 crul/0.5.0"
#> 
#> 
#> $origin
#> [1] "50.22.155.214"
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
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Foo\": \"bar\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"                                                                                                                                                      
#> [2] "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Content-Length\": \"0\", \n    \"Content-Type\": \"application/x-www-form-urlencoded\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"json\": null, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/post\"\n}\n"
```

## TO DO

### http caching

Add integration for:

* [vcr](https://github.com/ropensci/vcr)

for flexible and easy HTTP request caching

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/crul/issues).
* License: MIT
* Get citation information for `crul` in R doing `citation(package = 'crul')`
* Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
