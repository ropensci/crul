#' Make a handle
#'
#' @export
#' @param url (character) A url. required.
#' @param ... options passed on to [curl::new_handle()]
#' @examples
#' handle("https://hb.opencpu.org")
#'
#' # handles - pass in your own handle
#' \dontrun{
#' h <- handle("https://hb.opencpu.org")
#' (res <- HttpClient$new(handle = h))
#' out <- res$get("get")
#' }
handle <- function(url, ...) {
  list(url = url, handle = curl::new_handle(...))
}

handle_pop <- function(url) {
  name <- handle_make(url)
  if (exists(name, envir = crul_global_pool)) {
    rm(list = name, envir = crul_global_pool)
  }
}

handle_make <- function(x) {
  urltools::url_compose(urltools::url_parse(x))
}

crul_global_pool <- new.env(hash = TRUE, parent = emptyenv())

handle_find <- function(x) {
  z <- handle_make(x)
  if (exists(z, crul_global_pool)) {
    handle <- crul_global_pool[[z]]
  } else {
    handle <- handle(z)
    crul_global_pool[[z]] <- handle
  }
  return(handle)
}
