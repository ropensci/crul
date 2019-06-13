#' Base response object
#'
#' @export
#' @param url (character) A url, required
#' @param opts (list) curl options
#' @param handle A handle
#' @param method (character) HTTP method
#' @param status_code (integer) status code
#' @param request_headers (list) request headers, named list
#' @param response_headers (list) response headers, named list
#' @param response_headers_all (list) all response headers, including
#' intermediate redirect headers, unnamed list of named lists
#' @param modified (character) modified date
#' @param times (vector) named vector
#' @param content (raw) raw binary content response
#' @param request request object, with all details
#' @details
#' **Methods**
#'   \describe{
#'     \item{`parse(encoding = NULL, ...)`}{
#'       Parse the raw response content to text
#'       - encoding: A character string describing the current encoding.
#'         If left as `NULL`, we attempt to guess the encoding. Passed to
#'         `from` parameter in `iconv`
#'       - ...: additional parameters passed on to `iconv` (options: sub, mark, toRaw).
#'         See `?iconv` for help
#'     }
#'     \item{`success()`}{
#'       Was status code less than or equal to 201.
#'       returns boolean
#'     }
#'     \item{`status_http()`}{
#'       Get HTTP status code, message, and explanation
#'     }
#'     \item{`raise_for_status()`}{
#'       Check HTTP status and stop with appropriate
#'       HTTP error code and message if >= 300.
#'       - If you have `fauxpas` installed we use that,
#'       otherwise use \pkg{httpcode}
#'     }
#'   }
#' @format NULL
#' @usage NULL
#' @examples \dontrun{
#' x <- HttpResponse$new(method = "get", url = "https://httpbin.org")
#' x$url
#' x$method
#'
#' x <- HttpClient$new(url = 'https://httpbin.org')
#' (res <- x$get('get'))
#' res$request_headers
#' res$response_headers
#' res$parse()
#' res$status_code
#' res$status_http()
#' res$status_http()$status_code
#' res$status_http()$message
#' res$status_http()$explanation
#' res$success()
#'
#' x <- HttpClient$new(url = 'https://httpbin.org/status/404')
#' (res <- x$get())
#' # res$raise_for_status()
#'
#' x <- HttpClient$new(url = 'https://httpbin.org/status/414')
#' (res <- x$get())
#' # res$raise_for_status()
#' }
HttpResponse <- R6::R6Class(
  "HttpResponse",
  public = list(
    method = NULL,
    url = NULL,
    opts = NULL,
    handle = NULL,
    status_code = NULL,
    request_headers = NULL,
    response_headers = NULL,
    response_headers_all = NULL,
    modified = NULL,
    times = NULL,
    content = NULL,
    request = NULL,

    print = function(x, ...) {
      cat("<crul response> ", sep = "\n")
      cat(paste0("  url: ", self$url), sep = "\n")

      cat("  request_headers: ", sep = "\n")
      if (length(self$request_headers)) {
        for (i in seq_along(self$request_headers)) {
          cat(sprintf("    %s: %s", names(self$request_headers)[i],
                      self$request_headers[[i]]), sep = "\n")
        }
      }

      cat("  response_headers: ", sep = "\n")
      if (length(self$response_headers)) {
        for (i in seq_along(self$response_headers)) {
          cat(sprintf("    %s: %s", names(self$response_headers)[i],
                      self$response_headers[[i]]), sep = "\n")
        }
      }

      params <- parse_params(self$url)
      if (!is.null(params)) {
        cat("  params: ", sep = "\n")
        for (i in seq_along(params)) {
          cat(paste0("    ", sub("=", ": ", params[[i]], "=")), sep = "\n")
        }
      }
      if (!is.null(self$status_code)) cat(paste0("  status: ",
                                                 self$status_code), sep = "\n")
      invisible(self)
    },

    initialize = function(method, url, opts, handle, status_code,
                          request_headers, response_headers,
                          response_headers_all, modified, times,
                          content, request) {

      if (!missing(method)) self$method <- method
      self$url <- url
      if (!missing(opts)) self$opts <- opts
      if (!missing(handle)) self$handle <- handle
      if (!missing(status_code)) self$status_code <- as.numeric(status_code)
      if (!missing(request_headers)) self$request_headers <- request_headers
      if (!missing(response_headers)) self$response_headers <- response_headers
      if (!missing(response_headers_all))
        self$response_headers_all <- response_headers_all
      if (!missing(modified)) self$modified <- modified
      if (!missing(times)) self$times <- times
      if (!missing(content)) self$content <- content
      if (!missing(request)) self$request <- request
    },

    parse = function(encoding = NULL, ...) {
      if (
        "disk" %in% names(self$request) ||
        (inherits(self$request, "HttpRequest") && 
          "disk" %in% names(self$request$payload))
      ) {
        if (
          inherits(self$request, "HttpRequest") &&
          length(self$content) == 0
        ) {
          pld <- self$request$payload$disk
        } else if (inherits(self$content, "raw")) {
          return(parse_content(self$content, encoding, ...))
        } else {
          pld <- self$content
        }
        raw <- readBin(pld, "raw", file.info(pld)$size)
        return(rawToChar(raw))
      }
      if ("stream" %in% names(self$request)) {
        return(raw(0))
      }
      parse_content(self$content, encoding, ...)
    },

    success = function() {
      self$status_code < 400L && self$status_code >= 200L
    },

    status_http = function(verbose = FALSE) {
      httpcode::http_code(code = self$status_code, verbose = verbose)
    },

    raise_for_status = function() {
      if (self$status_code >= 300) {
        if (!requireNamespace("fauxpas", quietly = TRUE)) {
          x <- httpcode::http_code(code = self$status_code)
          stop(sprintf("%s (HTTP %s)", x$message, x$status_code), call. = FALSE)
        } else {
          fauxpas::http(self, behavior = "stop")
        }
      }
    }
  )
)

guess_encoding <- function(encoding = NULL) {
  if (!is.null(encoding)) {
    return(check_encoding(encoding))
  } else {
    message("No encoding supplied: defaulting to UTF-8.")
    return("UTF-8")
  }
}

check_encoding <- function(x) {
  if ((tolower(x) %in% tolower(iconvlist()))) return(x)
  message("Invalid encoding ", x, ": defaulting to UTF-8.")
  "UTF-8"
}

parse_params <- function(x) {
  x <- urltools::parameters(x)
  if (is.na(x)) {
    NULL
  } else {
    strsplit(x, "&")[[1]]
  }
}

parse_content <- function(x, encoding, ...) {
  iconv(x = readBin(x, character()),
    from = guess_encoding(encoding), to = "UTF-8", ...)
}
