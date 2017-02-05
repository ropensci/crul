<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{async}
%\VignetteEncoding{UTF-8}
-->



async with crul
===============

Asynchronous requests with `crul`.

There are two interfaces to asynchronous requests in `crul`:

1. Simple async: any number of URLs, all treated with the same curl options, headers, etc., and only one HTTP method type at a time.
2. Varied request async: build any type of request and execute all asynchronously. 

The first option takes less thinking, less work, and is good solution when you just want to hit a bunch of URLs asynchronously. 

The second option is ideal when you want to set curl options/headers on each request and/or want to do different types of HTTP methods on each request.


```r
library("crul")
```

## simple async

Build request objcect with 1 or more URLs




```r
(cc <- Async$new(
  urls = c(
    'http://localhost:9000/get?a=5',
    'http://localhost:9000/get?a=5&b=6',
    'http://localhost:9000/ip'
  )
))
#> <crul async connection> 
#>   urls: 
#>    http://localhost:9000/get?a=5
#>    http://localhost:9000/get?a=5&b=6
#>    http://localhost:9000/ip
```

Make request with any HTTP method


```r
(res <- cc$get())
#> [[1]]
#> <crul response> 
#>   url: http://localhost:9000/get?a=5&b=6
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.0 200 OK
#>     content-type: application/json
#>     content-length: 341
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     server: Werkzeug/0.10.4 Python/2.7.9
#>     date: Sun, 05 Feb 2017 01:06:51 GMT
#>   params: 
#>     a: 5
#>     b: 6
#>   status: 200
#> 
#> [[2]]
#> <crul response> 
#>   url: http://localhost:9000/ip
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.0 200 OK
#>     content-type: application/json
#>     content-length: 28
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     server: Werkzeug/0.10.4 Python/2.7.9
#>     date: Sun, 05 Feb 2017 01:06:51 GMT
#>   status: 200
#> 
#> [[3]]
#> <crul response> 
#>   url: http://localhost:9000/get?a=5
#>   request_headers: 
#>   response_headers: 
#>     status: HTTP/1.0 200 OK
#>     content-type: application/json
#>     content-length: 323
#>     access-control-allow-origin: *
#>     access-control-allow-credentials: true
#>     server: Werkzeug/0.10.4 Python/2.7.9
#>     date: Sun, 05 Feb 2017 01:06:51 GMT
#>   params: 
#>     a: 5
#>   status: 200
```

You get back a list matching length of the number of input URLs

Access object variables and methods just as with `HttpClient` results, here just one at a time.


```r
res[[1]]$url
#> [1] "http://localhost:9000/get?a=5&b=6"
res[[1]]$success()
#> [1] TRUE
res[[1]]$parse("UTF-8")
#> [1] "{\n  \"args\": {\n    \"a\": \"5\",\n    \"b\": \"6\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip, deflate\",\n    \"Content-Length\": \"\",\n    \"Content-Type\": \"\",\n    \"Host\": \"localhost:9000\",\n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810\"\n  },\n  \"origin\": \"127.0.0.1\",\n  \"url\": \"http://localhost:9000/get?a=5&b=6\"\n}\n"
```

Or apply access/method calls aross many results, e.g., parse all results


```r
lapply(res, function(z) z$parse("UTF-8"))
#> [[1]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\",\n    \"b\": \"6\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip, deflate\",\n    \"Content-Length\": \"\",\n    \"Content-Type\": \"\",\n    \"Host\": \"localhost:9000\",\n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810\"\n  },\n  \"origin\": \"127.0.0.1\",\n  \"url\": \"http://localhost:9000/get?a=5&b=6\"\n}\n"
#> 
#> [[2]]
#> [1] "{\n  \"origin\": \"127.0.0.1\"\n}\n"
#> 
#> [[3]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip, deflate\",\n    \"Content-Length\": \"\",\n    \"Content-Type\": \"\",\n    \"Host\": \"localhost:9000\",\n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810\"\n  },\n  \"origin\": \"127.0.0.1\",\n  \"url\": \"http://localhost:9000/get?a=5\"\n}\n"
```

## varied request async


```r
req1 <- HttpRequest$new(
  url = "http://localhost:9000/get?a=5",
  opts = list(
    verbose = TRUE
  )
)
req1$get()
#> <crul connection> 
#>   url: http://localhost:9000/get?a=5
#>   options: 
#>     verbose: TRUE
#>   proxies: 
#>   headers:

req2 <- HttpRequest$new(
  url = "http://localhost:9000/post?a=5&b=6",
  method = "post"
)
req2$post(body = list(a = 5))
#> <crul connection> 
#>   url: http://localhost:9000/post?a=5&b=6
#>   options: 
#>   proxies: 
#>   headers:

(res <- AsyncVaried$new(req1, req2))
#> <crul async connection> 
#>   requests: 
#>     http://localhost:9000/get?a=5 
#>     http://localhost:9000/post?a=5&b=6
```

Make requests asynchronously


```r
res$request()
```

Parse all results


```r
res$parse()
#> [1] "{\n  \"args\": {\n    \"a\": \"5\",\n    \"b\": \"6\"\n  },\n  \"data\": \"\",\n  \"files\": {},\n  \"form\": {\n    \"a\": \"5\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip, deflate\",\n    \"Content-Length\": \"137\",\n    \"Content-Type\": \"multipart/form-data; boundary=------------------------8816e2f505041b80\",\n    \"Expect\": \"100-continue\",\n    \"Host\": \"localhost:9000\",\n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810\"\n  },\n  \"json\": null,\n  \"origin\": \"127.0.0.1\",\n  \"url\": \"http://localhost:9000/post?a=5&b=6\"\n}\n"
#> [2] "{\n  \"args\": {\n    \"a\": \"5\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip, deflate\",\n    \"Content-Length\": \"\",\n    \"Content-Type\": \"\",\n    \"Host\": \"localhost:9000\",\n    \"User-Agent\": \"libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810\"\n  },\n  \"origin\": \"127.0.0.1\",\n  \"url\": \"http://localhost:9000/get?a=5\"\n}\n"
```


```r
lapply(res$parse(), jsonlite::prettify)
#> [[1]]
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
#>         "Content-Type": "multipart/form-data; boundary=------------------------8816e2f505041b80",
#>         "Expect": "100-continue",
#>         "Host": "localhost:9000",
#>         "User-Agent": "libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810"
#>     },
#>     "json": null,
#>     "origin": "127.0.0.1",
#>     "url": "http://localhost:9000/post?a=5&b=6"
#> }
#>  
#> 
#> [[2]]
#> {
#>     "args": {
#>         "a": "5"
#>     },
#>     "headers": {
#>         "Accept": "*/*",
#>         "Accept-Encoding": "gzip, deflate",
#>         "Content-Length": "",
#>         "Content-Type": "",
#>         "Host": "localhost:9000",
#>         "User-Agent": "libcurl/7.51.0 r-curl/2.3 crul/0.2.2.9810"
#>     },
#>     "origin": "127.0.0.1",
#>     "url": "http://localhost:9000/get?a=5"
#> }
#> 
```

Status codes


```r
res$status_code()
#> [1] 200 200
```
