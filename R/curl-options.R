#' curl options
#'
#' With the \code{opts} parameter you can pass in various
#' curl options, including user agent string, whether to get verbose
#' curl output or not, setting a timeout for requests, and more. See
#' \code{\link[curl]{curl_options}} for all the options you can use.
#'
#' A progress helper will be coming soon.
#'
#' @name curl-options
#' @aliases user-agent verbose timeout
#'
#' @examples
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
#' \dontrun{res$get('get', stuff = "things")}
#' \dontrun{res$get('get', httpget = TRUE)}
#'
#' # set a timeout
#' (res <- HttpClient$new(
#'   url = "https://httpbin.org",
#'   opts = list(timeout_ms = 1)
#' ))
#' \dontrun{res$get('get')}
NULL
