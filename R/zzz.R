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
    options = ccp(as.list(c(opts$opts, cainfo = find_cert_bundle()))),
    headers = as.list(c(opts$type, def_head())),
    fields = opts$fields
  )
  rr$headers <- norm_headers(rr$headers, self$headers)
  rr$options <- utils::modifyList(
    rr$options,
    c(self$opts, self$proxies, self$auth, ...)
  )
  rr$options <- curl_opts_fil(rr$options)
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

def_head <- function() {
  list(
    `User-Agent` = make_ua(),
    `Accept-Encoding` = 'gzip, deflate',
    `Accept` = 'application/json, text/xml, application/xml, */*'
  )
}

# drop any options that are not in the set of
# valid curl options
curl_opts_fil <- function(z) {
  valco <- names(curl::curl_options())
  z[names(z) %in% valco]
}

# drop named things
drop_name <- function(x, y) {
  x[!names(x) %in% y]
}

# adapted from https://github.com/hadley/httr
find_cert_bundle <- function() {
  if (.Platform$OS.type != "windows")
    return()

  env <- Sys.getenv("CURL_CA_BUNDLE")
  if (!identical(env, ""))
    return(env)

  bundled <- file.path(R.home("etc"), "curl-ca-bundle.crt")
  if (file.exists(bundled))
    return(bundled)

  # Fall back to certificate bundle in openssl
  system.file("cacert.pem", package = "openssl")
}
