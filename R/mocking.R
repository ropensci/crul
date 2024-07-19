#' Mocking HTTP requests
#' 
#' Works for both synchronous requests via [HttpClient()] and async
#' requests via [Async()] and [AsyncVaried()]
#'
#' @export
#' @param on (logical) turn mocking on with `TRUE` or turn off with `FALSE`.
#' By default is `FALSE`
#' @details `webmockr` package required for mocking behavior
#' @examples \dontrun{
#' 
#' if (interactive()) {
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
#' 
#'   # With Async
#'   urls <- c(
#'    file.path(URL, "get"),
#'    file.path(URL, "anything"),
#'    file.path(URL, "encoding/utf8")
#'   )
#'   
#'   for (u in urls) {
#'     webmockr::stub_request("get", u) %>% 
#'       webmockr::to_return(body = list(mocked = TRUE))
#'   }
#' 
#'   async_con <- Async$new(urls = urls)
#'   async_resp <- async_con$get()
#'   lapply(async_resp, \(x) x$parse("UTF-8"))
#' }
#' 
#' }
mock <- function(on = TRUE) {
  check_for_package("webmockr")
  crul_opts$mock <- on
}
