#' Mocking HTTP requests
#'
#' @name mocking
#' @examples
#' # load webmockr
#' library(webmockr)
#' library(crul)
#'
#' # turn on mocking
#' webmockr::enable()
#' crul::mock()
#' crul:::crul_opts$mock
#'
#' # stub a request
#' webmockr::stub_request("get", "http://localhost:9000/get")
#' webmockr:::webmockr_stub_registry
#'
#' # create an HTTP client
#' (x <- HttpClient$new(url = "http://localhost:9000"))
#'
#' # make a request - first one is executed, and following requests
#' # pull from the cache
#' x$get('get') # http request made
#' x$get('get') # not http request made, pulled from cache
NULL

crul_opts <- new.env()
crul_opts$mock <- FALSE

#' @export
mock <- function(on = TRUE) crul_opts$mock <- on
