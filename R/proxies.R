#' proxy options
#'
#' @name proxies
#' @param url (character) URL, with scheme (http/https), domain and
#' port (must be numeric). required.
#' @param user (character) username, optional
#' @param pwd (character) password, optional
#' @param auth (character) authentication type, one of basic (default),
#' digest, digest_ie, gssnegotiate, ntlm, or any. optional
#'
#' @details See <http://proxylist.hidemyass.com/> for a list of proxies you
#' can use
#'
#' @examples
#' proxy("http://97.77.104.22:3128")
#' proxy("97.77.104.22:3128")
#' proxy("http://97.77.104.22:3128", "foo", "bar")
#' proxy("http://97.77.104.22:3128", "foo", "bar", auth = "digest")
#' proxy("http://97.77.104.22:3128", "foo", "bar", auth = "ntlm")
#'
#' # with proxy (look at request/outgoing headers)
#' (res <- HttpClient$new(
#'   url = "http://www.google.com",
#'   proxies = proxy("http://97.77.104.22:3128")
#' ))
#' res$proxies
#' \dontrun{res$get(verbose = TRUE)}
#'
#' # vs. without proxy (look at request/outgoing headers)
#' (res2 <- HttpClient$new(url = "http://www.google.com"))
#' res2$get(verbose = TRUE)
#'
#'
#' # Use authentication
#' (res <- HttpClient$new(
#'   url = "http://google.com",
#'   proxies = proxy("http://97.77.104.22:3128", user = "foo", pwd = "bar")
#' ))
#'
#' # another example
#' (res <- HttpClient$new(
#'   url = "http://ip.tyk.nu/",
#'   proxies = proxy("http://200.29.191.149:3128")
#' ))
#' \dontrun{res$get()$parse("UTF-8")}
NULL

#' @export
#' @rdname proxies
proxy <- function(url, user = NULL, pwd = NULL, auth = "basic") {
  url <- proxy_url(url)
  structure(ccp(list(
    proxy = url$domain,
    proxyport = url$port,
    proxyuserpwd = make_up(user, pwd),
    proxyauth = auth_type(auth)
  )), class = "proxy")
}

proxy_url <- function(x) {
  tmp <- tryCatch(urltools::url_parse(x), error = function(e) e)
  if (inherits(tmp, "error")) {
    stop("proxy URL not of correct form, check your URL", call. = FALSE)
  }
  port <- tryCatch(as.numeric(tmp$port), warning = function(w) w)
  if (inherits(port, "warning")) stop("port ", tmp$port, " was not numeric",
                                      call. = FALSE)
  tmp$port <- port
  as.list(tmp)
}

make_up <- function(user, pwd) {
  assert(user, "character")
  assert(pwd, "character")
  if (!is.null(user) || !is.null(pwd)) {
    return(paste0(user, ":", pwd))
  }
  NULL
}

auth_type <- function(x) {
  stopifnot(inherits(x, "character"))
  switch(
    x,
    basic = 1,
    digest = 2,
    digest_ie = 16,
    gssnegotiate = 4,
    ntlm = 8,
    any = -17,
    stop("auth not in acceptable set, see ?proxies", call. = FALSE)
  )
}

purl <- function(x) {
  sprintf("http://%s:%s (auth: %s)",
          x$proxy, x$proxyport, !is.null(x$proxyuserpwd))
}
