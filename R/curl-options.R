#' curl options
#'
#' @name curl-options
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
NULL
