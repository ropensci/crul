#' check if a url is okay
#' 
#' @export
#' @param x either a URL as a character string, or an object of 
#' class [HttpClient]
#' @param status (integer) one or more HTTP status codes, must be integers.
#' default: `200L`, since this is the most common signal
#' that a URL is okay, but there may be cases in which your URL
#' is okay if it's a `201L`, or some other status code.
#' @param info (logical) in the case of an error, do you want a 
#' `message()` about it? Default: `TRUE`
#' @param verb (character) use "head" (default) or "get" HTTP verb
#' for the request. note that "get" will take longer as it returns a
#' body. however, "verb=get" may be your only option if a url
#' blocks head requests
#' @param ua_random (logical) use a random user agent string?
#' default: `TRUE`. if you set `useragent` curl option it will override
#' this setting. The random user agent string is pulled from a vector of
#' 50 user agent strings generated from `charlatan::UserAgentProvider`
#' (by executing `replicate(30, UserAgentProvider$new()$user_agent())`)
#' @param ... args passed on to [HttpClient]
#' @return a single boolean, if `TRUE` the URL is up and okay, 
#' if `FALSE` it is down; but, see Details
#' @details We internally verify that status is an integer and 
#' in the known set of HTTP status codes, and that info is a boolean
#' 
#' You may have to fiddle with the parameters to `ok()` as well as
#' curl options to get the "right answer". If you think you are getting
#' incorrectly getting `FALSE`, the first thing to do is to pass in
#' `verbose=TRUE` to `ok()`. That will give you verbose curl output and will
#' help determine what the issue may be. Here's some different scenarios:
#' 
#' - the site blocks head requests: some sites do this, try `verb="get"`
#' - it will be hard to determine a site that requires this, but it's
#' worth trying a random useragent string, e.g., `ok(useragent = "foobar")`
#' - some sites are up and reachable but you could get a 403 Unauthorized
#' error, there's nothing you can do in this case other than having access
#' - its possible to get a weird HTTP status code, e.g., LinkedIn gives
#' a 999 code, they're trying to prevent any programmatic access
#' 
#' A `FALSE` result may be incorrect depending on the use case. For example,
#' if you want to know if curl based scraping will work without fiddling with
#' curl options, then the `FALSE` is probably correct, but if you want to
#' fiddle with curl options, then first step would be to send `verbose=TRUE`
#' to see whats going on with any redirects and headers. You can set headers,
#' user agent strings, etc. to get closer to the request you want to know
#' about. Note that a user agent string is always passed by default, but it
#' may not be the one you want.
#' 
#' @examples \dontrun{
#' # 200
#' ok("https://www.google.com") 
#' # 200
#' ok("https://httpbin.org/status/200")
#' # more than one status
#' ok("https://www.google.com", status = c(200L, 202L))
#' # 404
#' ok("https://httpbin.org/status/404")
#' # doesn't exist
#' ok("https://stuff.bar")
#' # doesn't exist
#' ok("stuff")
#' 
#' # use get verb instead of head
#' ok("http://animalnexus.ca")
#' ok("http://animalnexus.ca", verb = "get")
#' 
#' # some urls will require a different useragent string
#' # they probably regex the useragent string
#' ok("https://doi.org/10.1093/chemse/bjq042")
#' ok("https://doi.org/10.1093/chemse/bjq042", verb = "get", useragent = "foobar")
#' 
#' # with random user agent's
#' ## here, use a request hook to print out just the user agent string so 
#' ## we can see what user agent string is being sent off
#' fun_ua <- function(request) {
#'   message(paste0("User-agent: ", request$options$useragent), sep = "\n")
#' }
#' z <- crul::HttpClient$new("https://doi.org/10.1093/chemse/bjq042", 
#'  hooks = list(request = fun_ua))
#' z
#' replicate(5, ok(z, ua_random=TRUE), simplify=FALSE)
#' ## if you set useragent option it will override ua_random=TRUE
#' ok("https://doi.org/10.1093/chemse/bjq042", useragent="foobar", ua_random=TRUE)
#' 
#' # with HttpClient
#' z <- crul::HttpClient$new("https://httpbin.org/status/404", 
#'  opts = list(verbose = TRUE))
#' ok(z)
#' }
ok <- function(x, status=200L, info=TRUE, verb="head", ua_random=FALSE, ...) {
  UseMethod("ok")
}

#' @export
ok.default <- function(x, status=200L, info=TRUE, verb="head",
  ua_random=FALSE, ...) {
  stop("no 'ok' method for ", class(x)[[1L]], call. = FALSE)
}

#' @export
ok.character <- function(x, status=200L, info=TRUE, verb="head",
  ua_random=FALSE, ...) {
  z <- crul::HttpClient$new(x, opts = list(...))
  ok(z, status, info, verb, ua_random, ...)
}

#' @export
ok.HttpClient <- function(x, status=200L, info=TRUE, verb="head",
  ua_random=FALSE, ...) {
  assert(info, "logical")
  assert(status, "integer")
  assert_opts(verb, c("head", "get"))
  assert(ua_random, "logical")
  # set ua
  if (ua_random) x$opts$useragent <- sample(agents, size=1)
  for (i in seq_along(status)) {
    ts <- tryCatch(httpcode::http_code(status[i]), error = function(e) e)
    if (inherits(ts, "error"))
      stop("status [", status[i], "] not in acceptable set")
  }

  w <- tryCatch(x$verb(verb), error = function(e) e)
  if (inherits(w, "error")) {
    if (info) message(w$message)
    return(FALSE)
  }
  w$status_code %in% status
}
