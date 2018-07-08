#' HTTP DELETE requests
#'
#' @name delete-requests
#' @examples \dontrun{
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#'
#' ## a list
#' (res1 <- x$delete('delete', body = list(hello = "world"), verbose = TRUE))
#' jsonlite::fromJSON(res1$parse("UTF-8"))
#'
#' ## a string
#' (res2 <- x$delete('delete', body = "hello world", verbose = TRUE))
#' jsonlite::fromJSON(res2$parse("UTF-8"))
#'
#' ## empty body request
#' x$delete('delete', verbose = TRUE)
#' }
NULL
