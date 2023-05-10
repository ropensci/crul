#' Mocking HTTP requests
#'
#' @export
#' @param on (logical) turn mocking on with `TRUE` or turn off with `FALSE`.
#' By default is `FALSE`
#' @details `webmockr` package required for mocking behavior
#' @examples \dontrun{
#' 
#' if (interactive()) {
#'   # load webmockr
#'   library(webmockr)
#'   library(crul)
#'
#'   URL <- "https://hb.opencpu.org"
#'
#'   # turn on mocking
#'   crul::mock()
#'
#'   # stub a request
#'   stub_request("get", file.path(URL, "get"))
#'   webmockr:::webmockr_stub_registry
#'
#'   # create an HTTP client
#'   (x <- HttpClient$new(url = URL))
#'
#'   # make a request - matches stub - no real request made
#'   x$get('get')
#'
#'   # allow net connect
#'   webmockr::webmockr_allow_net_connect()
#'   x$get('get', query = list(foo = "bar"))
#'   webmockr::webmockr_disable_net_connect()
#'   x$get('get', query = list(foo = "bar"))
#' }
#' 
#' }
mock <- function(on = TRUE) {
  check_for_package("webmockr")
  crul_opts$mock <- on
}
