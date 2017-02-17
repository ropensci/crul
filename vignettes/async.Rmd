<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{async}
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


```r
library("crul")
```

## simple async

Build request objcect with 1 or more URLs




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
#>   url: https://httpbin.org/ip
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     server: nginx
#>     date: Fri, 17 Feb 2017 17:50:17 GMT
#>     content-type: application/json
#>     content-length: 33
#>     connection: keep-alive
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>   status: 200
#> 
#> [[2]]
#> <crul response> 
#>   url: https://httpbin.org/get?a=5
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     server: nginx
#>     date: Fri, 17 Feb 2017 17:50:17 GMT
#>     content-type: application/json
#>     content-length: 279
#>     connection: keep-alive
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>   params: 
#>     a: 5
#>   status: 200
#> 
#> [[3]]
#> <crul response> 
#>   url: https://httpbin.org/get?a=5&b=6
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.1 200 OK
#>     server: nginx
#>     date: Fri, 17 Feb 2017 17:50:17 GMT
#>     content-type: application/json
#>     content-length: 298
#>     connection: keep-alive
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>   params: 
#>     a: 5
#>     b: 6
#>   status: 200
```

You get back a list matching length of the number of input URLs

Access object variables and methods just as with `HttpClient` results, here just one at a time.


```r
res[[1]]$url
#> [1] "https://httpbin.org/ip"
res[[1]]$success()
#> [1] TRUE
res[[1]]$parse("UTF-8")
#> [1] "{\n  \"origin\": \"157.130.179.86\"\n}\n"
```

Or apply access/method calls aross many results, e.g., parse all results


```r
lapply(res, function(z) z$parse("UTF-8"))
#> [[1]]
#> [1] "{\n  \"origin\": \"157.130.179.86\"\n}\n"
#> 
#> [[2]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"
#> 
#> [[3]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\", \n    \"b\": \"6\"\n  }, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get?a=5&b=6\"\n}\n"
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
#> <crul http request> 
#>   url: https://httpbin.org/get?a=5
#>   options: 
#>     verbose: TRUE
#>   proxies: 
#>   headers:

req2 <- HttpRequest$new(
  url = "https://httpbin.org/post?a=5&b=6",
  method = "post"
)
req2$post(body = list(a = 5))
#> <crul http request> 
#>   url: https://httpbin.org/post?a=5&b=6
#>   options: 
#>   proxies: 
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
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"                                                                                                                                                                                                                                                                   
#> [2] "{\n  \"args\": {\n    \"a\": \"5\", \n    \"b\": \"6\"\n  }, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Content-Length\": \"137\", \n    \"Content-Type\": \"multipart/form-data; boundary=------------------------121b91d0764ddd51\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100\"\n  }, \n  \"json\": null, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/post?a=5&b=6\"\n}\n"
```


```r
lapply(res$parse(), jsonlite::prettify)
#> [[1]]
#> {
#>     "args": {
#>         "a": "5"
#>     },
#>     "headers": {
#>         "Accept": "*/*",
#>         "Accept-Encoding": "gzip, deflate",
#>         "Host": "httpbin.org",
#>         "User-Agent": "libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100"
#>     },
#>     "origin": "157.130.179.86",
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
#>         "Accept": "*/*",
#>         "Accept-Encoding": "gzip, deflate",
#>         "Content-Length": "137",
#>         "Content-Type": "multipart/form-data; boundary=------------------------121b91d0764ddd51",
#>         "Host": "httpbin.org",
#>         "User-Agent": "libcurl/7.51.0 r-curl/2.3 crul/0.2.7.9100"
#>     },
#>     "json": null,
#>     "origin": "157.130.179.86",
#>     "url": "https://httpbin.org/post?a=5&b=6"
#> }
#> 
```

Status codes


```r
res$status_code()
#> [1] 200 200
```
