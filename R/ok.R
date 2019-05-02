#' check if a url is okay
#' 
#' @export
#' @param x either a URL as a character string, or an object of 
#' class [HttpClient]
#' @param status (integer) an HTTP status code, must be an integer. 
#' By default this is 200L, since this is the most common signal
#' that a URL is okay, but there may be cases in which your URL
#' is okay if it's a 201L, or some other status code.
#' @param info (logical) in the case of an error, do you want a 
#' `message()` about it? Default: `TRUE`
#' @param ... args passed on to [HttpClient]
#' @return a single boolean, if `TRUE` the URL is up and okay, 
#' if `FALSE` it is down.
#' @details We internally verify that status is an integer and 
#' in the known set of HTTP status codes, and that info is a boolean
#' @examples \dontrun{
#' # 200
#' ok("https://google.com") 
#' # 200
#' ok("https://httpbin.org/status/200")
#' # 404
#' ok("https://httpbin.org/status/404")
#' # doesn't exist
#' ok("https://stuff.bar")
#' # doesn't exist
#' ok("stuff")
#' 
#' # with HttpClient
#' z <- crul::HttpClient$new("https://httpbin.org/status/404", 
#'  opts = list(verbose = TRUE))
#' ok(z)
#' }
ok <- function(x, status = 200L, info = TRUE, ...) {
  UseMethod("ok")
}

#' @export
ok.default <- function(x, status = 200L, info = TRUE, ...) {
  stop("no 'ok' method for ", class(x)[[1L]], call. = FALSE)
}

#' @export
ok.character <- function(x, status = 200L, info = TRUE, ...) {
  z <- crul::HttpClient$new(x, opts = list(...))
  ok(z, status, info, ...)
}

#' @export
ok.HttpClient <- function(x, status = 200L, info = TRUE, ...) {
  assert(info, "logical")
  assert(status, "integer")
  
  find_status <- tryCatch(httpcode::http_code(status), 
                          error = function(e) e)
  
  if (inherits(find_status, "error")) stop("status [", status, "] not in acceptable set")
  w <- tryCatch(x$head(), error = function(e) e)
  if (inherits(w, "error")) {
    if (info) message(w$message)
    return(FALSE)
  }
  w$status_code == status
}
