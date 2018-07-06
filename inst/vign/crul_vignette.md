<!--
%\VignetteIndexEntry{1. crul introduction}
%\VignetteEngine{knitr::rmarkdown}
%\VignetteEncoding{UTF-8}
-->



crul introduction
=================

`crul` is an HTTP client for R.

## Install

Stable CRAN version


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
#> [1] 503
```

The content


```r
res$content
#>  [1] 7b 22 73 74 61 74 75 73 22 3a 22 35 30 33 22 2c 22 64 65 73 63 72 69
#> [24] 70 74 69 6f 6e 22 3a 22 54 68 65 20 64 65 70 6c 6f 79 6d 65 6e 74 20
#> [47] 69 73 20 63 75 72 72 65 6e 74 6c 79 20 75 6e 61 76 61 69 6c 61 62 6c
#> [70] 65 22 7d 0a
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
#> [1] "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521"
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
#> [1] "HTTP/1.1 503 Service Temporarily Unavailable"
#> 
#> $date
#> [1] "Fri, 06 Jul 2018 23:18:54 GMT"
#> 
#> $`content-type`
#> [1] "application/json"
#> 
#> $`content-length`
#> [1] "73"
#> 
#> $connection
#> [1] "keep-alive"
#> 
#> $etag
#> [1] "\"5b22ab07-49\""
#> 
#> $vary
#> [1] "Accept"
#> 
#> $`x-now-trace`
#> [1] "sfo1"
#> 
#> $server
#> [1] "now"
#> 
#> $`cache-control`
#> [1] "max-age=0"
```

And you can parse the content with a provided function:


```r
res$parse()
#> [1] "{\"status\":\"503\",\"description\":\"The deployment is currently unavailable\"}\n"
jsonlite::fromJSON(res$parse())
#> $status
#> [1] "503"
#> 
#> $description
#> [1] "The deployment is currently unavailable"
```

With the `HttpClient` object, which holds any configuration stuff
we set, we can make other HTTP verb requests. For example, a `HEAD`
request:


```r
x$post(
  path = "post", 
  body = list(hello = "world")
)
```


## write to disk


```r
x <- HttpClient$new(url = "https://httpbin.org")
f <- tempfile()
res <- x$get(disk = f)
# when using write to disk, content is a path
res$content 
#> [1] "/var/folders/fc/n7g_vrvn0sx_st0p8lxb3ts40000gn/T//Rtmpj01EFF/file7e173a5b4450"
```

Read lines


```r
readLines(res$content, n = 10)
#> [1] "{\"status\":\"503\",\"description\":\"The deployment is currently unavailable\"}"
```

## stream data


```r
(x <- HttpClient$new(url = "https://httpbin.org"))
#> <crul connection> 
#>   url: https://httpbin.org
#>   curl options: 
#>   proxies: 
#>   auth: 
#>   headers: 
#>   progress: FALSE
res <- x$get('stream/5', stream = function(x) cat(rawToChar(x)))
#> {"url": "https://httpbin.org/stream/5", "args": {}, "headers": {"Host": "httpbin.org", "Connection": "close", "User-Agent": "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521", "Accept-Encoding": "gzip, deflate", "Accept": "application/json, text/xml, application/xml, */*"}, "origin": "157.130.179.86", "id": 0}
#> {"url": "https://httpbin.org/stream/5", "args": {}, "headers": {"Host": "httpbin.org", "Connection": "close", "User-Agent": "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521", "Accept-Encoding": "gzip, deflate", "Accept": "application/json, text/xml, application/xml, */*"}, "origin": "157.130.179.86", "id": 1}
#> {"url": "https://httpbin.org/stream/5", "args": {}, "headers": {"Host": "httpbin.org", "Connection": "close", "User-Agent": "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521", "Accept-Encoding": "gzip, deflate", "Accept": "application/json, text/xml, application/xml, */*"}, "origin": "157.130.179.86", "id": 2}
#> {"url": "https://httpbin.org/stream/5", "args": {}, "headers": {"Host": "httpbin.org", "Connection": "close", "User-Agent": "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521", "Accept-Encoding": "gzip, deflate", "Accept": "application/json, text/xml, application/xml, */*"}, "origin": "157.130.179.86", "id": 3}
#> {"url": "https://httpbin.org/stream/5", "args": {}, "headers": {"Host": "httpbin.org", "Connection": "close", "User-Agent": "libcurl/7.54.0 r-curl/3.2 crul/0.5.4.9521", "Accept-Encoding": "gzip, deflate", "Accept": "application/json, text/xml, application/xml, */*"}, "origin": "157.130.179.86", "id": 4}
# when streaming, content is NULL
res$content 
#> NULL
```
