#' Make a handle
#'
#' @export
#' @param url (character) A url. required.
#' @param ... options passed on to \code{\link[curl]{new_handle}}
#' @examples
#' handle("https://httpbin.org")
#'
#' # handles - pass in your own handle
#' h <- handle("https://httpbin.org")
#' (res <- HttpClient$new(handle = h))
#' out <- res$get("get")
handle <- function(url, ...) {
  list(url = url, handle = curl::new_handle(...))
}
