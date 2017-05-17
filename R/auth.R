#' Authentication
#'
#' @export
#' @param user (character) username, optional
#' @param pwd (character) password, optional
#' @param auth (character) authentication type, one of basic (default),
#' digest, digest_ie, gssnegotiate, ntlm, or any. optional
#' @details
#' Only supporting simple auth for now, OAuth later.
#' @examples
#' auth(user = "foo", pwd = "bar", auth = "basic")
#' auth(user = "foo", pwd = "bar", auth = "digest")
#' auth(user = "foo", pwd = "bar", auth = "ntlm")
#' auth(user = "foo", pwd = "bar", auth = "any")
#'
#' # with HttpClient
#' (res <- HttpClient$new(
#'   url = "https://httpbin.org/basic-auth/user/passwd",
#'   auth = auth(user = "user", pwd = "passwd")
#' ))
#' res$auth
#' x <- res$get()
#' jsonlite::fromJSON(x$parse("UTF-8"))
#'
#' # with HttpRequest
#' (res <- HttpRequest$new(
#'   url = "https://httpbin.org/basic-auth/user/passwd",
#'   auth = auth(user = "user", pwd = "passwd")
#' ))
#' res$auth
auth <- function(user, pwd, auth = "basic") {
  structure(ccp(list(
    userpwd = make_up(user, pwd),
    httpauth = auth_type(auth)
  )), class = "auth", type = auth)
}
