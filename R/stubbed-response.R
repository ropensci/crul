#' stubbed response object
#'
#' @export
#' @param url (character) A url
#' @param opts (list) curl options
#' @param handle A handle
#' @details
#' \strong{Methods}
#'   \describe{
#'     \item{\code{parse()}}{
#'       Parse the raw response content to text
#'     }
#'     \item{\code{success()}}{
#'       Was status code less than or equal to 201.
#'       returns boolean
#'     }
#'     \item{\code{status_http()}}{
#'       Get HTTP status code, message, and explanation
#'     }
#'     \item{\code{raise_for_status()}}{
#'       Check HTTP status and stop with appropriate
#'       HTTP error code and message if >= 300.
#'       - If you have \code{fauxpas} installed we use that,
#'       otherwise use \pkg{httpcode}
#'     }
#'   }
#' @format NULL
#' @usage NULL
#' @examples
#' (x <- HttpStubbedResponse$new(method = "get", url = "https://httpbin.org"))
#' x$url
#' x$method
HttpStubbedResponse <- R6::R6Class(
  'HttpStubbedResponse',
  public = list(
    method = NULL,
    url = NULL,
    opts = NULL,
    handle = NULL,
    status_code = NULL,
    request_headers = NULL,
    content = NULL,
    request = NULL,

    print = function(x, ...) {
      cat("<crul stubbed response> ", sep = "\n")
      cat(paste0("  url: ", self$url), sep = "\n")
      cat("  request_headers: ", sep = "\n")
      for (i in seq_along(self$request_headers)) {
        cat(sprintf("    %s: %s", names(self$request_headers)[i], self$request_headers[[i]]), sep = "\n")
      }
      cat("  response_headers: NULL", sep = "\n")
      params <- parse_params(self$url)
      if (!is.null(params)) {
        cat("  params: ", sep = "\n")
        for (i in seq_along(params)) {
          cat(paste0("    ", sub("=", ": ", params[[i]], "=")), sep = "\n")
        }
      }
      if (!is.null(self$status_code)) cat(paste0("  status: ", self$status_code), sep = "\n")
      invisible(self)
    },

    initialize = function(method, url, opts, handle, status_code, request_headers,
                          content, request) {
      if (!missing(method)) self$method <- method
      if (!missing(url)) self$url <- url
      if (!missing(opts)) self$opts <- opts
      if (!missing(handle)) self$handle <- handle
      if (!missing(status_code)) self$status_code <- as.numeric(status_code)
      if (!missing(request_headers)) self$request_headers <- request_headers
      if (!missing(content)) self$content <- content
      if (!missing(request)) self$request <- request
    },

    parse = function(encoding = NULL) {
      iconv(readBin(self$content, character()),
            from = guess_encoding(encoding),
            to = "UTF-8")
    },

    success = function() {
      self$status_code <= 201
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
