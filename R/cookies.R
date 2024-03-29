#' Working with cookies
#'
#' @name cookies
#' @examples \dontrun{
#' x <- HttpClient$new(
#'   url = "https://hb.opencpu.org",
#'   opts = list(
#'     cookie = "c=1;f=5",
#'     verbose = TRUE
#'   )
#' )
#' x
#'
#' # set cookies
#' (res <- x$get("cookies"))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' (x <- HttpClient$new(url = "https://hb.opencpu.org"))
#' res <- x$get("cookies/set", query = list(foo = 123, bar = "ftw"))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#' curl::handle_cookies(handle = res$handle)
#'
#' # reuse handle
#' res2 <- x$get("get", query = list(hello = "world"))
#' jsonlite::fromJSON(res2$parse("UTF-8"))
#' curl::handle_cookies(handle = res2$handle)
#'
#' # DOAJ
#' x <- HttpClient$new(url = "https://doaj.org")
#' res <- x$get("api/v1/journals/f3f2e7f23d444370ae5f5199f85bc100",
#'   verbose = TRUE)
#' res$response_headers$`set-cookie`
#' curl::handle_cookies(handle = res$handle)
#' res2 <- x$get("api/v1/journals/9abfb36b06404e8a8566e1a44180bbdc",
#'   verbose = TRUE)
#'
#' ## reset handle
#' x$handle_pop()
#' ## cookies no longer sent, as handle reset
#' res2 <- x$get("api/v1/journals/9abfb36b06404e8a8566e1a44180bbdc",
#'   verbose = TRUE)
#' }
NULL
