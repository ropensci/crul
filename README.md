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

Mocking:

`crul` now integrates with [webmockr](https://github.com/ropensci/webmockr) to mock
HTTP requests.

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
#> [254] 30 20 72 2d 63 75 72 6c 2f 32 2e 38 2e 31 20 63 72 75 6c 2f 30 2e 34
#> [277] 2e 30 22 0a 20 20 7d 2c 20 0a 20 20 22 6f 72 69 67 69 6e 22 3a 20 22
#> [300] 31 35 37 2e 31 33 30 2e 31 37 39 2e 38 36 22 2c 20 0a 20 20 22 75 72
#> [323] 6c 22 3a 20 22 68 74 74 70 73 3a 2f 2f 68 74 74 70 62 69 6e 2e 6f 72
#> [346] 67 2f 67 65 74 22 0a 7d 0a
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
#> [1] "libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0"
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
#> [1] "Mon, 02 Oct 2017 19:20:21 GMT"
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
#> [1] "0.000764131546021"
#> 
#> $`content-length`
#> [1] "354"
#> 
#> $via
#> [1] "1.1 vegur"
```

And you can parse the content with `parse()`


```r
res$parse()
#> No encoding supplied: defaulting to UTF-8.
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"A\": \"hello world\", \n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"
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
#> [1] "libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0"
#> 
#> 
#> $origin
#> [1] "157.130.179.86"
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
#> <crul async connection> 
#>   urls: 
#>    https://httpbin.org/
#>    https://httpbin.org/get?a=5
#>    https://httpbin.org/get?foo=bar
res <- cc$get()
lapply(res, function(z) z$parse("UTF-8"))
#> [[1]]
#> [1] "<!DOCTYPE html>\n<html>\n<head>\n  <meta http-equiv='content-type' value='text/html;charset=utf8'>\n  <meta name='generator' value='Ronn/v0.7.3 (http://github.com/rtomayko/ronn/tree/0.7.3)'>\n  <title>httpbin(1): HTTP Client Testing Service</title>\n  <style type='text/css' media='all'>\n  /* style: man */\n  body#manpage {margin:0}\n  .mp {max-width:100ex;padding:0 9ex 1ex 4ex}\n  .mp p,.mp pre,.mp ul,.mp ol,.mp dl {margin:0 0 20px 0}\n  .mp h2 {margin:10px 0 0 0}\n  .mp > p,.mp > pre,.mp > ul,.mp > ol,.mp > dl {margin-left:8ex}\n  .mp h3 {margin:0 0 0 4ex}\n  .mp dt {margin:0;clear:left}\n  .mp dt.flush {float:left;width:8ex}\n  .mp dd {margin:0 0 0 9ex}\n  .mp h1,.mp h2,.mp h3,.mp h4 {clear:left}\n  .mp pre {margin-bottom:20px}\n  .mp pre+h2,.mp pre+h3 {margin-top:22px}\n  .mp h2+pre,.mp h3+pre {margin-top:5px}\n  .mp img {display:block;margin:auto}\n  .mp h1.man-title {display:none}\n  .mp,.mp code,.mp pre,.mp tt,.mp kbd,.mp samp,.mp h3,.mp h4 {font-family:monospace;font-size:14px;line-height:1.42857142857143}\n  .mp h2 {font-size:16px;line-height:1.25}\n  .mp h1 {font-size:20px;line-height:2}\n  .mp {text-align:justify;background:#fff}\n  .mp,.mp code,.mp pre,.mp pre code,.mp tt,.mp kbd,.mp samp {color:#131211}\n  .mp h1,.mp h2,.mp h3,.mp h4 {color:#030201}\n  .mp u {text-decoration:underline}\n  .mp code,.mp strong,.mp b {font-weight:bold;color:#131211}\n  .mp em,.mp var {font-style:italic;color:#232221;text-decoration:none}\n  .mp a,.mp a:link,.mp a:hover,.mp a code,.mp a pre,.mp a tt,.mp a kbd,.mp a samp {color:#0000ff}\n  .mp b.man-ref {font-weight:normal;color:#434241}\n  .mp pre {padding:0 4ex}\n  .mp pre code {font-weight:normal;color:#434241}\n  .mp h2+pre,h3+pre {padding-left:0}\n  ol.man-decor,ol.man-decor li {margin:3px 0 10px 0;padding:0;float:left;width:33%;list-style-type:none;text-transform:uppercase;color:#999;letter-spacing:1px}\n  ol.man-decor {width:100%}\n  ol.man-decor li.tl {text-align:left}\n  ol.man-decor li.tc {text-align:center;letter-spacing:4px}\n  ol.man-decor li.tr {text-align:right;float:right}\n  </style>\n  <style type='text/css' media='all'>\n  /* style: 80c */\n  .mp {max-width:86ex}\n  ul {list-style: None; margin-left: 1em!important}\n  .man-navigation {left:101ex}\n  </style>\n</head>\n\n<body id='manpage'>\n<a href=\"http://github.com/kennethreitz/httpbin\"><img style=\"position: absolute; top: 0; right: 0; border: 0;\" src=\"https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png\" alt=\"Fork me on GitHub\"></a>\n\n\n\n<div class='mp'>\n<h1>httpbin(1): HTTP Request &amp; Response Service</h1>\n<p>Freely hosted in <a href=\"http://httpbin.org\">HTTP</a>, <a href=\"https://httpbin.org\">HTTPS</a>, &amp; <a href=\"http://eu.httpbin.org/\">EU</a> flavors by <a href=\"http://kennethreitz.org/bitcoin\">Kenneth Reitz</a> &amp; <a href=\"https://www.runscope.com/\">Runscope</a>.</p>\n\n<h2 id=\"BONUSPOINTS\">BONUSPOINTS</h2>\n\n<ul>\n<li><a href=\"https://now.httpbin.org/\" data-bare-link=\"true\"><code>now.httpbin.org</code></a> The current time, in a variety of formats.</li>\n</ul>\n\n<h2 id=\"ENDPOINTS\">ENDPOINTS</h2>\n\n<ul>\n<li><a href=\"/\" data-bare-link=\"true\"><code>/</code></a> This page.</li>\n<li><a href=\"/ip\" data-bare-link=\"true\"><code>/ip</code></a> Returns Origin IP.</li>\n<li><a href=\"/uuid\" data-bare-link=\"true\"><code>/uuid</code></a> Returns UUID4.</li>\n<li><a href=\"/user-agent\" data-bare-link=\"true\"><code>/user-agent</code></a> Returns user-agent.</li>\n<li><a href=\"/headers\" data-bare-link=\"true\"><code>/headers</code></a> Returns header dict.</li>\n<li><a href=\"/get\" data-bare-link=\"true\"><code>/get</code></a> Returns GET data.</li>\n<li><code>/post</code> Returns POST data.</li>\n<li><code>/patch</code> Returns PATCH data.</li>\n<li><code>/put</code> Returns PUT data.</li>\n<li><code>/delete</code> Returns DELETE data</li>\n<li><a href=\"/anything\" data-bare-link=\"true\"><code>/anything</code></a> Returns request data, including method used.</li>\n<li><code>/anything/:anything</code> Returns request data, including the URL.</li>\n<li><a href=\"/encoding/utf8\"><code>/encoding/utf8</code></a> Returns page containing UTF-8 data.</li>\n<li><a href=\"/gzip\" data-bare-link=\"true\"><code>/gzip</code></a> Returns gzip-encoded data.</li>\n<li><a href=\"/deflate\" data-bare-link=\"true\"><code>/deflate</code></a> Returns deflate-encoded data.</li>\n<li><a href=\"/brotli\" data-bare-link=\"true\"><code>/brotli</code></a> Returns brotli-encoded data.</li>\n<li><a href=\"/status/418\"><code>/status/:code</code></a> Returns given HTTP Status code.</li>\n<li><a href=\"/response-headers?Server=httpbin&amp;Content-Type=text%2Fplain%3B+charset%3DUTF-8\"><code>/response-headers?key=val</code></a> Returns given response headers.</li>\n<li><a href=\"/redirect/6\"><code>/redirect/:n</code></a> 302 Redirects <em>n</em> times.</li>\n<li><a href=\"/redirect-to?url=http%3A%2F%2Fexample.com%2F\"><code>/redirect-to?url=foo</code></a> 302 Redirects to the <em>foo</em> URL.</li>\n<li><a href=\"/redirect-to?status_code=307&amp;url=http%3A%2F%2Fexample.com%2F\"><code>/redirect-to?url=foo&status_code=307</code></a> 307 Redirects to the <em>foo</em> URL.</li>\n<li><a href=\"/relative-redirect/6\"><code>/relative-redirect/:n</code></a> 302 Relative redirects <em>n</em> times.</li>\n<li><a href=\"/absolute-redirect/6\"><code>/absolute-redirect/:n</code></a> 302 Absolute redirects <em>n</em> times.</li>\n<li><a href=\"/cookies\" data-bare-link=\"true\"><code>/cookies</code></a> Returns cookie data.</li>\n<li><a href=\"/cookies/set?k1=v1&amp;k2=v2\"><code>/cookies/set?name=value</code></a> Sets one or more simple cookies.</li>\n<li><a href=\"/cookies/delete?k1=&amp;k2=\"><code>/cookies/delete?name</code></a> Deletes one or more simple cookies.</li>\n<li><a href=\"/basic-auth/user/passwd\"><code>/basic-auth/:user/:passwd</code></a> Challenges HTTPBasic Auth.</li>\n<li><a href=\"/hidden-basic-auth/user/passwd\"><code>/hidden-basic-auth/:user/:passwd</code></a> 404'd BasicAuth.</li>\n<li><a href=\"/digest-auth/auth/user/passwd/MD5/never\"><code>/digest-auth/:qop/:user/:passwd/:algorithm</code></a> Challenges HTTP Digest Auth.</li>\n<li><a href=\"/digest-auth/auth/user/passwd/MD5/never\"><code>/digest-auth/:qop/:user/:passwd</code></a> Challenges HTTP Digest Auth.</li>\n<li><a href=\"/stream/20\"><code>/stream/:n</code></a> Streams <em>min(n, 100)</em> lines.</li>\n<li><a href=\"/delay/3\"><code>/delay/:n</code></a> Delays responding for <em>min(n, 10)</em> seconds.</li>\n<li><a href=\"/drip?code=200&amp;numbytes=5&amp;duration=5\"><code>/drip?numbytes=n&amp;duration=s&amp;delay=s&amp;code=code</code></a> Drips data over a duration after an optional initial delay, then (optionally) returns with the given status code.</li>\n<li><a href=\"/range/1024\"><code>/range/1024?duration=s&amp;chunk_size=code</code></a> Streams <em>n</em> bytes, and allows specifying a <em>Range</em> header to select a subset of the data. Accepts a <em>chunk_size</em> and request <em>duration</em> parameter.</li>\n<li><a href=\"/html\" data-bare-link=\"true\"><code>/html</code></a> Renders an HTML Page.</li>\n<li><a href=\"/robots.txt\" data-bare-link=\"true\"><code>/robots.txt</code></a> Returns some robots.txt rules.</li>\n<li><a href=\"/deny\" data-bare-link=\"true\"><code>/deny</code></a> Denied by robots.txt file.</li>\n<li><a href=\"/cache\" data-bare-link=\"true\"><code>/cache</code></a> Returns 200 unless an If-Modified-Since or If-None-Match header is provided, when it returns a 304.</li>\n<li><a href=\"/etag/etag\"><code>/etag/:etag</code></a> Assumes the resource has the given etag and responds to If-None-Match header with a 200 or 304 and If-Match with a 200 or 412 as appropriate.</li>\n<li><a href=\"/cache/60\"><code>/cache/:n</code></a> Sets a Cache-Control header for <em>n</em> seconds.</li>\n<li><a href=\"/bytes/1024\"><code>/bytes/:n</code></a> Generates <em>n</em> random bytes of binary data, accepts optional <em>seed</em> integer parameter.</li>\n<li><a href=\"/stream-bytes/1024\"><code>/stream-bytes/:n</code></a> Streams <em>n</em> random bytes of binary data in chunked encoding, accepts optional <em>seed</em> and <em>chunk_size</em> integer parameters.</li>\n<li><a href=\"/links/10\"><code>/links/:n</code></a> Returns page containing <em>n</em> HTML links.</li>\n<li><a href=\"/image\"><code>/image</code></a> Returns page containing an image based on sent Accept header.</li>\n<li><a href=\"/image/png\"><code>/image/png</code></a> Returns a PNG image.</li>\n<li><a href=\"/image/jpeg\"><code>/image/jpeg</code></a> Returns a JPEG image.</li>\n<li><a href=\"/image/webp\"><code>/image/webp</code></a> Returns a WEBP image.</li>\n<li><a href=\"/image/svg\"><code>/image/svg</code></a> Returns a SVG image.</li>\n<li><a href=\"/forms/post\" data-bare-link=\"true\"><code>/forms/post</code></a> HTML form that submits to <em>/post</em></li>\n<li><a href=\"/xml\" data-bare-link=\"true\"><code>/xml</code></a> Returns some XML</li>\n</ul>\n\n<h2 id=\"DESCRIPTION\">DESCRIPTION</h2>\n\n<p>Testing an HTTP Library can become difficult sometimes. <a href=\"http://requestb.in\">RequestBin</a> is fantastic for testing POST requests, but doesn't let you control the response. This exists to cover all kinds of HTTP scenarios. Additional endpoints are being considered.</p>\n\n<p>All endpoint responses are JSON-encoded.</p>\n\n<h2 id=\"EXAMPLES\">EXAMPLES</h2>\n\n<h3 id=\"-curl-http-httpbin-org-ip\">$ curl http://httpbin.org/ip</h3>\n\n<pre><code>{\"origin\": \"24.127.96.129\"}\n</code></pre>\n\n<h3 id=\"-curl-http-httpbin-org-user-agent\">$ curl http://httpbin.org/user-agent</h3>\n\n<pre><code>{\"user-agent\": \"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\"}\n</code></pre>\n\n<h3 id=\"-curl-http-httpbin-org-get\">$ curl http://httpbin.org/get</h3>\n\n<pre><code>{\n   \"args\": {},\n   \"headers\": {\n      \"Accept\": \"*/*\",\n      \"Connection\": \"close\",\n      \"Content-Length\": \"\",\n      \"Content-Type\": \"\",\n      \"Host\": \"httpbin.org\",\n      \"User-Agent\": \"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\"\n   },\n   \"origin\": \"24.127.96.129\",\n   \"url\": \"http://httpbin.org/get\"\n}\n</code></pre>\n\n<h3 id=\"-curl-I-http-httpbin-org-status-418\">$ curl -I http://httpbin.org/status/418</h3>\n\n<pre><code>HTTP/1.1 418 I'M A TEAPOT\nServer: nginx/0.7.67\nDate: Mon, 13 Jun 2011 04:25:38 GMT\nConnection: close\nx-more-info: http://tools.ietf.org/html/rfc2324\nContent-Length: 135\n</code></pre>\n\n<h3 id=\"-curl-https-httpbin-org-get-show_env-1\">$ curl https://httpbin.org/get?show_env=1</h3>\n\n<pre><code>{\n  \"headers\": {\n    \"Content-Length\": \"\",\n    \"Accept-Language\": \"en-US,en;q=0.8\",\n    \"Accept-Encoding\": \"gzip,deflate,sdch\",\n    \"X-Forwarded-Port\": \"443\",\n    \"X-Forwarded-For\": \"109.60.101.240\",\n    \"Host\": \"httpbin.org\",\n    \"Accept\": \"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\",\n    \"User-Agent\": \"Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.83 Safari/535.11\",\n    \"X-Request-Start\": \"1350053933441\",\n    \"Accept-Charset\": \"ISO-8859-1,utf-8;q=0.7,*;q=0.3\",\n    \"Connection\": \"keep-alive\",\n    \"X-Forwarded-Proto\": \"https\",\n    \"Cookie\": \"_gauges_unique_day=1; _gauges_unique_month=1; _gauges_unique_year=1; _gauges_unique=1; _gauges_unique_hour=1\",\n    \"Content-Type\": \"\"\n  },\n  \"args\": {\n    \"show_env\": \"1\"\n  },\n  \"origin\": \"109.60.101.240\",\n  \"url\": \"http://httpbin.org/get?show_env=1\"\n}\n</code></pre>\n\n<h2 id=\"Installing-and-running-from-PyPI\">Installing and running from PyPI</h2>\n\n<p>You can install httpbin as a library from PyPI and run it as a WSGI app.  For example, using Gunicorn:</p>\n\n<pre><code class=\"bash\">$ pip install httpbin\n$ gunicorn httpbin:app\n</code></pre>\n\n\n<h2 id=\"AUTHOR\">AUTHOR</h2>\n\n<p>A <a href=\"http://kennethreitz.com/\">Kenneth Reitz</a> project.</p>\n<p>BTC: <a href=\"https://www.kennethreitz.org/bitcoin\"><code>1Me2iXTJ91FYZhrGvaGaRDCBtnZ4KdxCug</code></a></p>\n\n<h2 id=\"SEE-ALSO\">SEE ALSO</h2>\n\n<p><a href=\"https://www.hurl.it\">Hurl.it</a> - Make HTTP requests.</p>\n<p><a href=\"http://requestb.in\">RequestBin</a> - Inspect HTTP requests.</p>\n<p><a href=\"http://python-requests.org\" data-bare-link=\"true\">http://python-requests.org</a></p>\n\n</div>\n\n\n    \n<script type=\"text/javascript\">\n  (function() {\n    window._pa = window._pa || {};\n    _pa.productId = \"httpbin\";\n    var pa = document.createElement('script'); pa.type = 'text/javascript'; pa.async = true;\n    pa.src = ('https:' == document.location.protocol ? 'https:' : 'http:') + \"//tag.perfectaudience.com/serve/5226171f87bc6890da0000a0.js\";\n    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(pa, s);\n  })();\n</script>\n\n<script type=\"text/javascript\">\n  var _gauges = _gauges || [];\n  (function() {\n    var t   = document.createElement('script');\n    t.type  = 'text/javascript';\n    t.async = true;\n    t.id    = 'gauges-tracker';\n    t.setAttribute('data-site-id', '58cb2e71c88d9043ac01d000');\n    t.setAttribute('data-track-path', 'https://track.gaug.es/track.gif');\n    t.src = 'https://d36ee2fcip1434.cloudfront.net/track.js';\n    var s = document.getElementsByTagName('script')[0];\n    s.parentNode.insertBefore(t, s);\n  })();\n</script>\n\n\n</body>\n</html>"
#> 
#> [[2]]
#> [1] "{\n  \"args\": {\n    \"a\": \"5\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get?a=5\"\n}\n"
#> 
#> [[3]]
#> [1] "{\n  \"args\": {\n    \"foo\": \"bar\"\n  }, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get?foo=bar\"\n}\n"
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
#> [1] "{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Foo\": \"bar\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0\"\n  }, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/get\"\n}\n"                                                                                                                                                      
#> [2] "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json, text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"close\", \n    \"Content-Length\": \"0\", \n    \"Content-Type\": \"application/x-www-form-urlencoded\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"libcurl/7.54.0 r-curl/2.8.1 crul/0.4.0\"\n  }, \n  \"json\": null, \n  \"origin\": \"157.130.179.86\", \n  \"url\": \"https://httpbin.org/post\"\n}\n"
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
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.
