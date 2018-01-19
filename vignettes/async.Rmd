<!--
%\VignetteIndexEntry{async with crul}
%\VignetteEngine{knitr::rmarkdown}
%\VignetteEncoding{UTF-8}
-->

async with crul
===============



Asynchronous requests with `crul`.

There are two interfaces to asynchronous requests in `crul`:

1. Simple async: any number of URLs, all treated with the same curl options,
headers, etc., and only one HTTP method type at a time.
2. Varied request async: build any type of request and execute all asynchronously.

The first option takes less thinking, less work, and is good solution when you
just want to hit a bunch of URLs asynchronously.

The second option is ideal when you want to set curl options/headers on each
request and/or want to do different types of HTTP methods on each request.

One thing to think about before using async is whether the data provider is
okay with it. It's possible that a data provider's service may be brought down
if you do too many async requests.


```r
library("crul")
```

## simple async

Build request object with 1 or more URLs




```r
(cc <- Async$new(
  urls = c(
    'https://httpbin.org/get?a=5',
    'https://httpbin.org/get?a=5&b=6',
    'https://httpbin.org/ip'
  )
))
#> <crul async connection> 
#>   urls: 
#>    https://httpbin.org/get?a=5
#>    https://httpbin.org/get?a=5&b=6
#>    https://httpbin.org/ip
```

Make request with any HTTP method


```r
(res <- cc$get())
#> [[1]]
#> <crul response> 
#>   url: https://httpbin.org/get?a=5
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     connection: keep-alive
#>     server: meinheld/0.6.1
#>     date: Fri, 19 Jan 2018 18:44:29 GMT
#>     content-type: application/json
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     x-powered-by: Flask
#>     x-processed-time: 0.000792026519775
#>     content-length: 346
#>     via: 1.1 vegur
#>   params: 
#>     a: 5
#>   status: 200
#> 
#> [[2]]
#> <crul response> 
#>   url: https://httpbin.org/get?a=5&b=6
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     connection: keep-alive
#>     server: meinheld/0.6.1
#>     date: Fri, 19 Jan 2018 18:44:29 GMT
#>     content-type: application/json
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     x-powered-by: Flask
#>     x-processed-time: 0.00130796432495
#>     content-length: 365
#>     via: 1.1 vegur
#>   params: 
#>     a: 5
#>     b: 6
#>   status: 200
#> 
#> [[3]]
#> <crul response> 
#>   url: https://httpbin.org/ip
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     connection: keep-alive
#>     server: meinheld/0.6.1
#>     date: Fri, 19 Jan 2018 18:44:28 GMT
#>     content-type: application/json
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     x-powered-by: Flask
#>     x-processed-time: 0.000822067260742
#>     content-length: 32
#>     via: 1.1 vegur
#>   status: 200
```

You get back a list matching length of the number of input URLs

Access object variables and methods just as with `HttpClient` results, here just one at a time.


```r
res[[1]]$url
#> [1] "https://httpbin.org/get?a=5"
res[[1]]$success()
#> [1] TRUE
res[[1]]$parse("UTF-8")
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"
```

Or apply access/method calls across many results, e.g., parse all results


```r
lapply(res, function(z) z$parse("UTF-8"))
#> [[1]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"
#> 
#> [[2]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\", \n    \"b\": \"6\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get?a=5&b=6\"\n}\n"
#> 
#> [[3]]
#> [1] "{\n  \"origin\": \"50.22.155.214\"\n}\n"
```

## varied request async


```r
req1 <- HttpRequest$new(
  url = "https://httpbin.org/get?a=5",
  opts = list(
    verbose = TRUE
  )
)
req1$get()
#> <crul http request> get
#>   url: https://httpbin.org/get?a=5
#>   curl options: 
#>     verbose: TRUE
#>   proxies: 
#>   auth: 
#>   headers:

req2 <- HttpRequest$new(
  url = "https://httpbin.org/post?a=5&b=6"
)
req2$post(body = list(a = 5))
#> <crul http request> post
#>   url: https://httpbin.org/post?a=5&b=6
#>   curl options: 
#>   proxies: 
#>   auth: 
#>   headers:

(res <- AsyncVaried$new(req1, req2))
#> <crul async varied connection> 
#>   requests: 
#>    get: https://httpbin.org/get?a=5 
#>    post: https://httpbin.org/post?a=5&b=6
```

Make requests asynchronously


```r
res$request()
```

Parse all results


```r
res$parse()
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"                                                                                                                                                                                                                                                                   
#> [2] "{\n  \"args\": {\n    \"a\": \"5\", \n    \"b\": \"6\"\n  }, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Content-Length\": \"137\", \n    \"Content-Type\": \"multipart/form-data; boundary=------------------------14f323a90518346b\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/3.1 crul/0.5.0\"\n  }, \n  \"json\": null, \n  \"origin\": \"50.22.155.214\", \n  \"url\": \"https://httpbin.org/post?a=5&b=6\"\n}\n"
```


```r
lapply(res$parse(), jsonlite::prettify)
#> [[1]]
#> {
#>     "args": {
#>         "a": "5"
#>     },
#>     "headers": {
#>         "Accept": "application/json, text/xml, application/xml, */*",
#>         "Accept-Encoding": "gzip, deflate",
#>         "Connection": "close",
#>         "Host": "httpbin.org",
#>         "User-Agent": "libcurl/7.54.0 r-curl/3.1 crul/0.5.0"
#>     },
#>     "origin": "50.22.155.214",
#>     "url": "https://httpbin.org/get?a=5"
#> }
#>  
#> 
#> [[2]]
#> {
#>     "args": {
#>         "a": "5",
#>         "b": "6"
#>     },
#>     "data": "",
#>     "files": {
#> 
#>     },
#>     "form": {
#>         "a": "5"
#>     },
#>     "headers": {
#>         "Accept": "application/json, text/xml, application/xml, */*",
#>         "Accept-Encoding": "gzip, deflate",
#>         "Connection": "close",
#>         "Content-Length": "137",
#>         "Content-Type": "multipart/form-data; boundary=------------------------14f323a90518346b",
#>         "Host": "httpbin.org",
#>         "User-Agent": "libcurl/7.54.0 r-curl/3.1 crul/0.5.0"
#>     },
#>     "json": null,
#>     "origin": "50.22.155.214",
#>     "url": "https://httpbin.org/post?a=5&b=6"
#> }
#> 
```

Status codes


```r
res$status_code()
#> [1] 200 200
```
