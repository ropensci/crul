#' Authentication
#'
#' @export
#' @param user (character) username, required. see Details.
#' @param pwd (character) password, required. see Details.
#' @param auth (character) authentication type, one of basic (default),
#' digest, digest_ie, gssnegotiate, ntlm, or any. required
#' 
#' @details
#' Only supporting simple auth for now, OAuth later maybe.
#' 
#' For `user` and `pwd` you are required to pass in some value. 
#' The value can be `NULL` to - which is equivalent to passing in an 
#' empty string like `""` in `httr::authenticate`. You may want to pass
#' in `NULL` for both `user` and `pwd` for example if you are using 
#' `gssnegotiate` auth type. See example below.
#' 
#' @examples
#' auth(user = "foo", pwd = "bar", auth = "basic")
#' auth(user = "foo", pwd = "bar", auth = "digest")
#' auth(user = "foo", pwd = "bar", auth = "ntlm")
#' auth(user = "foo", pwd = "bar", auth = "any")
#' 
#' # gssnegotiate auth
#' auth(NULL, NULL, "gssnegotiate")
#' 
#' \dontrun{
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
#' }
auth <- function(user, pwd, auth = "basic") {
  structure(ccp(list(
    userpwd = make_up(user, pwd),
    httpauth = auth_type(auth)
  )), class = "auth", type = auth)
}
