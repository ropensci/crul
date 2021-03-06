% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/async-queue.R
\name{AsyncQueue}
\alias{AsyncQueue}
\title{AsyncQueue}
\description{
An AsyncQueue client
}
\section{R6 classes}{

This is an R6 class from the package \pkg{R6}. Find out more
about R6 at \url{https://r6.r-lib.org/}. After creating an instance of an R6
class (e.g., \code{x <- HttpClient$new(url = "https://httpbin.org")}) you can
access values and methods on the object \code{x}.
}

\examples{
\dontrun{
# Using sleep
reqlist <- list(
  HttpRequest$new(url = "https://httpbin.org/get")$get(),
  HttpRequest$new(url = "https://httpbin.org/post")$post(),
  HttpRequest$new(url = "https://httpbin.org/put")$put(),
  HttpRequest$new(url = "https://httpbin.org/delete")$delete(),
  HttpRequest$new(url = "https://httpbin.org/get?g=5")$get(),
  HttpRequest$new(
    url = "https://httpbin.org/post")$post(body = list(y = 9)),
  HttpRequest$new(
    url = "https://httpbin.org/get")$get(query = list(hello = "world")),
  HttpRequest$new(url = "https://ropensci.org")$get(),
  HttpRequest$new(url = "https://ropensci.org/about")$get(),
  HttpRequest$new(url = "https://ropensci.org/packages")$get(),
  HttpRequest$new(url = "https://ropensci.org/community")$get(),
  HttpRequest$new(url = "https://ropensci.org/blog")$get(),
  HttpRequest$new(url = "https://ropensci.org/careers")$get()
)
out <- AsyncQueue$new(.list = reqlist, bucket_size = 5, sleep = 3)
out
out$bucket_size # bucket size
out$requests() # list requests
out$request() # make requests
out$responses() # list responses

# Using requests per minute
if (interactive()) {
x="https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/registry.json"
z <- HttpClient$new(x)$get()
urls <- jsonlite::fromJSON(z$parse("UTF-8"))$packages$url
repos = Filter(length, regmatches(urls, gregexpr("ropensci/[A-Za-z]+", urls)))
repos = unlist(repos)
auth <- list(Authorization = paste("token", Sys.getenv('GITHUB_PAT')))
reqs <- lapply(repos[1:50], function(w) {
  HttpRequest$new(paste0("https://api.github.com/repos/", w), headers = auth)$get()
})

out <- AsyncQueue$new(.list = reqs, req_per_min = 30)
out
out$bucket_size
out$requests()
out$request()
out$responses()
}}
}
\seealso{
Other async: 
\code{\link{AsyncVaried}},
\code{\link{Async}},
\code{\link{HttpRequest}}
}
\concept{async}
\section{Super class}{
\code{\link[crul:AsyncVaried]{crul::AsyncVaried}} -> \code{AsyncQueue}
}
\section{Public fields}{
\if{html}{\out{<div class="r6-fields">}}
\describe{
\item{\code{bucket_size}}{(integer) number of requests to send at once}

\item{\code{sleep}}{(integer) number of seconds to sleep between each bucket}

\item{\code{req_per_min}}{(integer) requests per minute}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-print}{\code{AsyncQueue$print()}}
\item \href{#method-new}{\code{AsyncQueue$new()}}
\item \href{#method-request}{\code{AsyncQueue$request()}}
\item \href{#method-responses}{\code{AsyncQueue$responses()}}
\item \href{#method-parse}{\code{AsyncQueue$parse()}}
\item \href{#method-status_code}{\code{AsyncQueue$status_code()}}
\item \href{#method-status}{\code{AsyncQueue$status()}}
\item \href{#method-content}{\code{AsyncQueue$content()}}
\item \href{#method-times}{\code{AsyncQueue$times()}}
\item \href{#method-clone}{\code{AsyncQueue$clone()}}
}
}
\if{html}{
\out{<details open ><summary>Inherited methods</summary>}
\itemize{
\item \out{<span class="pkg-link" data-pkg="crul" data-topic="AsyncVaried" data-id="requests">}\href{../../crul/html/AsyncVaried.html#method-requests}{\code{crul::AsyncVaried$requests()}}\out{</span>}
}
\out{</details>}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-print"></a>}}
\if{latex}{\out{\hypertarget{method-print}{}}}
\subsection{Method \code{print()}}{
print method for AsyncQueue objects
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$print(x, ...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{x}}{self}

\item{\code{...}}{ignored}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-new"></a>}}
\if{latex}{\out{\hypertarget{method-new}{}}}
\subsection{Method \code{new()}}{
Create a new \code{AsyncQueue} object
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$new(
  ...,
  .list = list(),
  bucket_size = 5,
  sleep = NULL,
  req_per_min = NULL
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{..., .list}}{Any number of objects of class \code{\link[=HttpRequest]{HttpRequest()}},
must supply inputs to one of these parameters, but not both}

\item{\code{bucket_size}}{(integer) number of requests to send at once.
default: 5. See Details.}

\item{\code{sleep}}{(integer) seconds to sleep between buckets.
default: NULL (not set)}

\item{\code{req_per_min}}{(integer) maximum number of requests per minute.
if \code{NULL} (default), its ignored}
}
\if{html}{\out{</div>}}
}
\subsection{Details}{
Must set either \code{sleep} or \code{req_per_min}. If you set
\code{req_per_min} we calculate a new \code{bucket_size} when \verb{$new()} is
called
}

\subsection{Returns}{
A new \code{AsyncQueue} object
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-request"></a>}}
\if{latex}{\out{\hypertarget{method-request}{}}}
\subsection{Method \code{request()}}{
Execute asynchronous requests
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$request()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
nothing, responses stored inside object, though will print
messages if you choose verbose output
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-responses"></a>}}
\if{latex}{\out{\hypertarget{method-responses}{}}}
\subsection{Method \code{responses()}}{
List responses
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$responses()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
a list of \code{HttpResponse} objects, empty list before
requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-parse"></a>}}
\if{latex}{\out{\hypertarget{method-parse}{}}}
\subsection{Method \code{parse()}}{
parse content
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$parse(encoding = "UTF-8")}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{encoding}}{(character) the encoding to use in parsing.
default:"UTF-8"}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
character vector, empty character vector before
requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-status_code"></a>}}
\if{latex}{\out{\hypertarget{method-status_code}{}}}
\subsection{Method \code{status_code()}}{
Get HTTP status codes for each response
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$status_code()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
numeric vector, empty numeric vector before requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-status"></a>}}
\if{latex}{\out{\hypertarget{method-status}{}}}
\subsection{Method \code{status()}}{
List HTTP status objects
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$status()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
a list of \code{http_code} objects, empty list before requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-content"></a>}}
\if{latex}{\out{\hypertarget{method-content}{}}}
\subsection{Method \code{content()}}{
Get raw content for each response
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$content()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
raw list, empty list before requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-times"></a>}}
\if{latex}{\out{\hypertarget{method-times}{}}}
\subsection{Method \code{times()}}{
curl request times
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$times()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
list of named numeric vectors, empty list before requests made
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-clone"></a>}}
\if{latex}{\out{\hypertarget{method-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{AsyncQueue$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
