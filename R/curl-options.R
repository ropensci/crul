#' curl options
#'
#' With the `opts` parameter you can pass in various
#' curl options, including user agent string, whether to get verbose
#' curl output or not, setting a timeout for requests, and more. See
#' [curl::curl_options()] for all the options you can use.
#'
#' A progress helper will be coming soon.
#'
#' @name curl-options
#' @aliases user-agent verbose timeout
#'
#' @examples \dontrun{
#' # set curl options on client initialization
#' (res <- HttpClient$new(
#'   url = "https://httpbin.org",
#'   opts = list(
#'     verbose = TRUE,
#'     useragent = "hello world"
#'   )
#' ))
#' res$opts
#' res$get('get')
#'
#' # or set curl options when performing HTTP operation
#' (res <- HttpClient$new(url = "https://httpbin.org"))
#' res$get('get', verbose = TRUE)
#' res$get('get', stuff = "things")
#' res$get('get', httpget = TRUE)
#'
#' # set a timeout
#' (res <- HttpClient$new(
#'   url = "https://httpbin.org",
#'   opts = list(timeout_ms = 1)
#' ))
#' res$get('get')
#' }
NULL
