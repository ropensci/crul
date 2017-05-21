`%||%` <- function(x, y) if (is.null(x)) y else x

ccp <- function(x) Filter(Negate(is.null), x)

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!class(x) %in% y) {
      stop(deparse(substitute(x)), " must be of class ",
           paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}

prep_opts <- function(method, url, self, opts, ...) {
  if (method != "post") {
    opts$opts$post <- NULL
    opts$opts$customrequest <- toupper(method)
  }
  if (!is.null(opts$type)) {
    if (nchar(opts$type[[1]]) == 0) {
      opts$type <- NULL
    }
  }
  rr <- list(
    url = url,
    method = method,
    options = as.list(c(
      opts$opts
    )),
    headers = as.list(c(
      opts$type,
      `User-Agent` = make_ua(),
      `Accept-Encoding` = 'gzip, deflate'
    )),
    fields = opts$fields
  )
  rr$headers <- norm_headers(rr$headers, self$headers)
  rr$options <- utils::modifyList(
    rr$options,
    c(self$opts, self$proxies, self$auth, ...)
  )
  return(rr)
}

norm_headers <- function(x, y) {
  if (length(names(y)) > 0) {
    x <- x[!names(x) %in% names(y)]
    x <- c(x, y)
  }
  return(x)
}

check_for_package <- function(x) {
  if (!requireNamespace(x, quietly = TRUE)) {
    stop(sprintf("Please install '%s'", x), call. = FALSE)
  } else {
    invisible(TRUE)
  }
}
