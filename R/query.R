# adapted from https://github.com/hadley/httr
encode <- function(x) {
  if (inherits(x, "AsIs")) {
    return(x)
  }
  curl::curl_escape(x)
}

has_namez <- function(x) {
  length(Filter(nzchar, names(x))) == length(x)
}

# adapted from https://github.com/hadley/httr
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    return(rep(FALSE, length(x)))
  }
  !is.na(nms) & nms != ""
}

# adapted from https://github.com/hadley/httr
make_query <- function(x) {
  if (length(x) == 0) {
    return("")
  }
  if (!all(has_name(x))) {
    stop("All components of query must be named", call. = FALSE)
  }
  stopifnot(is.list(x))
  x <- ccp(x)
  names <- curl::curl_escape(names(x))
  values <- vapply(x, encode, character(1))
  paste0(names, "=", values, collapse = "&")
}
