#' Base response object
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
#'   }
#' @format NULL
#' @usage NULL
#' @examples \dontrun{
#' x <- HttpResponse$new(method = "get", url = "https://httpbin.org")
#' x$url
#' x$method
#'
#' x <- HttpClient$new(url = 'http://sushi.com')
#' (res <- x$get('/nigiri/sake.json'))
#' res$parse()
#' res$status_code
#' res$status_http()
#' res$status_http()$status_code
#' res$status_http()$message
#' res$status_http()$explanation
#' res$raise_for_status()
#' res$success()
#' }
HttpResponse <- R6::R6Class(
  'HttpResponse',
  public = list(
    method = NULL,
    url = NULL,
    opts = NULL,
    handle = NULL,
    status_code = NULL,
    request_headers = NULL,
    response_headers = NULL,
    modified = NULL,
    times = NULL,
    content = NULL,
    request = NULL,

    print = function(x, ...) {
      cat("<crul response> ", sep = "\n")
      cat(paste0("  url: ", self$url), sep = "\n")
      cat("  request_headers: ", sep = "\n")
      for (i in seq_along(self$request_headers)) {
        cat(sprintf("    %s: %s", names(self$request_headers)[i], self$request_headers[[i]]), sep = "\n")
      }
      cat("  response_headers: ", sep = "\n")
      for (i in seq_along(self$response_headers)) {
        cat(paste0("    ", self$response_headers[[i]]), sep = "\n")
      }
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
                          response_headers, modified, times, content, request) {
      if (!missing(method)) self$method <- method
      if (!missing(url)) self$url <- url
      if (!missing(opts)) self$opts <- opts
      if (!missing(handle)) self$handle <- handle
      if (!missing(status_code)) self$status_code <- status_code
      if (!missing(request_headers)) self$request_headers <- request_headers
      if (!missing(response_headers)) self$response_headers <- response_headers
      if (!missing(modified)) self$modified <- modified
      if (!missing(times)) self$times <- times
      if (!missing(content)) self$content <- content
      if (!missing(request)) self$request <- request
    },

    parse = function(type, encoding) {
      readBin(self$content, character())
    },

    success = function() {
      self$status_code <= 201
    },

    status_http = function() {
      httpcode::http_code(code = self$status_code)
    }
  )
)

parse_params <- function(x) {
  x <- urltools::parameters(x)
  if (is.na(x)) {
    NULL
  } else {
    strsplit(x, "&")[[1]]
  }
}
