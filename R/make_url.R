make_url <- function(url = NULL, handle = NULL, path, query) {
  if (!is.null(handle)) {
    url <- handle$url
  } else {
    handle <- handle_find(url)
    url <- handle$url
  }
  if (!is.null(path)) {
    urltools::path(url) <- path
  }
  url <- gsub("\\s", "%20", url)
  url <- add_query(query, url)
  return(list(url = url, handle = handle$handle))
}

# query <- list(a = 5, a = 6)
# query <- list(a = 5)
# query <- list()
# add_query(query, "https://httpbin.org")
add_query <- function(x, url) {
  if (length(x)) {
    quer <- list()
    for (i in seq_along(x)) {
      if (!inherits(x[[i]], "AsIs")) {
        x[[i]] <- curl::curl_escape(num_format(x[[i]]))
      }
      quer[[i]] <- paste(curl::curl_escape(names(x)[i]),
        x[[i]], sep = "=")
    }
    parms <- paste0(quer, collapse = "&")
    paste0(url, "?", parms)
  } else {
    return(url)
  }
}

#' Build and parse URLs
#'
#' @export
#' @param url (character) a url, length 1
#' @param path (character) a path, length 1
#' @param query (list) a named list of query parameters
#' @return `url_build` returns a character string URL; `url_parse`
#' returns a list with URL components
#' @examples
#' url_build("https://httpbin.org")
#' url_build("https://httpbin.org", "get")
#' url_build("https://httpbin.org", "post")
#' url_build("https://httpbin.org", "get", list(foo = "bar"))
#'
#' url_parse("httpbin.org")
#' url_parse("http://httpbin.org")
#' url_parse(url = "https://httpbin.org")
#' url_parse("https://httpbin.org/get")
#' url_parse("https://httpbin.org/get?foo=bar")
#' url_parse("https://httpbin.org/get?foo=bar&stuff=things")
#' url_parse("https://httpbin.org/get?foo=bar&stuff=things[]")
url_build <- function(url, path = NULL, query = NULL) {
  assert(url, "character")
  assert(path, "character")
  assert(query, "list")
  stopifnot(length(url) == 1)
  if (!is.null(path)) stopifnot(length(path) <= 1)
  if (!has_namez(query)) stop("all query elements must be named", call. = FALSE)
  make_url(url, handle = NULL, path, query)$url
}

#' @export
#' @rdname url_build
url_parse <- function(url) {
  stopifnot(length(url) == 1, is.character(url))
  tmp <- urltools::url_parse(url)
  tmp <- as.list(tmp)
  if (!is.na(tmp$parameter)) {
    tmp$parameter <- unlist(
      lapply(strsplit(tmp$parameter, "&")[[1]], function(x) {
        z <- strsplit(x, split = "=")[[1]]
        as.list(stats::setNames(z[2], z[1]))
      }), FALSE)
  }
  return(tmp)
}
