crul
====



[![Build Status](https://travis-ci.org/ropenscilabs/crul.svg?branch=master)](https://travis-ci.org/ropenscilabs/crul)
[![codecov](https://codecov.io/gh/ropenscilabs/crul/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/crul)

An HTTP client, with perhaps the main goal being to hook into 
[webmockr](https://github.com/ropenscilabs/webmockr) and 
[vcr](https://github.com/ropenscilabs/vcr) for flexible and easy 
http request caching.

## Installation

CRAN version


```r
install.packages("crul")
```

Dev version


```r
install.packages("devtools")
devtools::install_github("ropenscilabs/crul")
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
#>   options: 
#>     timeout: 1
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

The content


```r
res$content
#>   [1] 7b 0a 20 20 22 61 72 67 73 22 3a 20 7b 7d 2c 20 0a 20 20 22 68 65 61
#>  [24] 64 65 72 73 22 3a 20 7b 0a 20 20 20 20 22 41 22 3a 20 22 68 65 6c 6c
#>  [47] 6f 20 77 6f 72 6c 64 22 2c 20 0a 20 20 20 20 22 41 63 63 65 70 74 22
#>  [70] 3a 20 22 2a 2f 2a 22 2c 20 0a 20 20 20 20 22 41 63 63 65 70 74 2d 45
#>  [93] 6e 63 6f 64 69 6e 67 22 3a 20 22 67 7a 69 70 2c 20 64 65 66 6c 61 74
#> [116] 65 22 2c 20 0a 20 20 20 20 22 48 6f 73 74 22 3a 20 22 68 74 74 70 62
#> [139] 69 6e 2e 6f 72 67 22 2c 20 0a 20 20 20 20 22 55 73 65 72 2d 41 67 65
#> [162] 6e 74 22 3a 20 22 6c 69 62 63 75 72 6c 2f 37 2e 34 39 2e 31 20 72 2d
#> [185] 63 75 72 6c 2f 32 2e 32 20 63 72 75 6c 2f 30 2e 30 2e 38 2e 39 30 30
#> [208] 30 22 0a 20 20 7d 2c 20 0a 20 20 22 6f 72 69 67 69 6e 22 3a 20 22 31
#> [231] 35 37 2e 31 33 30 2e 31 37 39 2e 38 36 22 2c 20 0a 20 20 22 75 72 6c
#> [254] 22 3a 20 22 68 74 74 70 73 3a 2f 2f 68 74 74 70 62 69 6e 2e 6f 72 67
#> [277] 2f 67 65 74 22 0a 7d 0a
```

HTTP method


```r
res$method
#> [1] "get"
```

Request headers


```r
res$request_headers
#> $a
#> [1] "hello world"
```

Response headers


```r
res$request_headers
#> $a
#> [1] "hello world"
```

And you can parse the content with a provided function:


```r
res$parse()
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"A\": \"hello world\", \n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.49.1 r-curl/2.2 crul/0.0.8.9000\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"
jsonlite::fromJSON(res$parse())
#> $args
#> named list()
#> 
#> $headers
#> $headers$A
#> [1] "hello world"
#> 
#> $headers$Accept
#> [1] "*/*"
#> 
#> $headers$`Accept-Encoding`
#> [1] "gzip, deflate"
#> 
#> $headers$Host
#> [1] "httpbin.org"
#> 
#> $headers$`User-Agent`
#> [1] "libcurl/7.49.1 r-curl/2.2 crul/0.0.8.9000"
#> 
#> 
#> $origin
#> [1] "157.130.179.86"
#> 
#> $url
#> [1] "https://httpbin.org/get"
```

## Meta

* Please [report any issues or bugs](https://github.com/ropenscilabs/crul/issues).
* License: MIT
* Get citation information for `crul` in R doing `citation(package = 'crul')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). 
By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
