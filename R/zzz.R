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
  rr <- list(
    url = url,
    method = method,
    options = as.list(c(
      opts$opts,
      useragent = make_ua()
    )),
    headers = c(self$headers, opts$type),
    fields = opts$fields
  )
  rr$options <- utils::modifyList(
    rr$options,
    c(self$opts, self$proxies, ...)
  )
  return(rr)
}
