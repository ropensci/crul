#' Mocking HTTP requests
#'
#' @export
#' @param on (logical) turn mocking on with `TRUE` or turn off with `FALSE`.
#' By default is `FALSE`
#' @examples \dontrun{
#' # load webmockr
#' library(webmockr)
#' library(crul)
#'
#' URL <- "https://httpbin.org"
#' # URL <- "http://localhost:9000"
#'
#' # turn on mocking
#' crul::mock()
#' crul:::crul_opts$mock
#'
#' # stub a request
#' stub_request("get", file.path(URL, "get"))
#' webmockr:::webmockr_stub_registry
#'
#' # create an HTTP client
#' (x <- HttpClient$new(url = URL))
#'
#' # make a request - first one is executed, and following requests
#' # pull from the cache
#' x$get('get') # http request made
#' x$get('get') # not http request made, pulled from cache
#'
#' # allow net connect
#' webmockr::webmockr_allow_net_connect()
#' x$get('get')
#' webmockr::webmockr_disable_net_connect()
#' x$get('get')
#' }
mock <- function(on = TRUE) crul_opts$mock <- on

## FIXME: seems like the request signature made in webmockr is not
## matching correctly to whats made in crul itself, check that
## the signature is matching correctly

## FIXME: when http requests made, and webmock enabled,
## requests should fail with message about how to register a
## stub for that exact request
