#' curl options
#'
#' With the `opts` parameter you can pass in various
#' curl options, including user agent string, whether to get verbose
#' curl output or not, setting a timeout for requests, and more. See
#' [curl::curl_options()] for all the options you can use. Note that
#' you need to give curl options exactly as given in
#' [curl::curl_options()].
#'
#' @name curl-options
#' @aliases user-agent verbose timeout
#'
#' @examples \dontrun{
#' url <- "https://hb.opencpu.org"
#'
#' # set curl options on client initialization
#' (res <- HttpClient$new(url = url, opts = list(verbose = TRUE)))
#' res$opts
#' res$get('get')
#'
#' # or set curl options when performing HTTP operation
#' (res <- HttpClient$new(url = url))
#' res$get('get', verbose = TRUE)
#' res$get('get', stuff = "things")
#'
#' # set a timeout
#' (res <- HttpClient$new(url = url, opts = list(timeout_ms = 1)))
#' # res$get('get')
#'
#' # set user agent either as a header or an option
#' HttpClient$new(url = url,
#'   headers = list(`User-Agent` = "hello world"),
#'   opts = list(verbose = TRUE)
#' )$get('get')
#'
#' HttpClient$new(url = url,
#'   opts = list(verbose = TRUE, useragent = "hello world")
#' )$get('get')
#'
#' # You can also set custom debug function via the verbose
#' # parameter when calling `$new()`
#' res <- HttpClient$new(url, verbose=curl_verbose())
#' res
#' res$get("get")
#' res <- HttpClient$new(url, verbose=curl_verbose(data_in=TRUE))
#' res$get("get")
#' res <- HttpClient$new(url, verbose=curl_verbose(info=TRUE))
#' res$get("get")
#' }
NULL
