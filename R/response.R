#' @title Base HTTP response object
#' @description Class with methods for handling HTTP responses
#' 
#' @export
#' @seealso [content-types]
#' @details
#' **Additional Methods**
#'   \describe{
#'     \item{`raise_for_ct(type, charset = NULL, behavior = "stop")`}{
#'       Check response content-type; stop or warn if not matched. Parameters:
#'       \itemize{
#'        \item type: (character) a mime type to match against; see
#'          [mime::mimemap] for allowed values
#'        \item charset: (character) if a charset string given, we check that
#'          it matches the charset in the content type header. default: NULL
#'        \item behavior: (character) one of stop (default) or warning
#'       }
#'     }
#'     \item{`raise_for_ct_html(charset = NULL, behavior = "stop")`}{
#'       Check that the response content-type is `text/html`; stop or warn if
#'       not matched. Parameters: see `raise_for_ct()`
#'     }
#'     \item{`raise_for_ct_json(charset = NULL, behavior = "stop")`}{
#'       Check that the response content-type is `application/json`; stop or
#'       warn if not matched. Parameters: see `raise_for_ct()`
#'     }
#'     \item{`raise_for_ct_xml(charset = NULL, behavior = "stop")`}{
#'       Check that the response content-type is `application/xml`; stop or warn if
#'       not matched. Parameters: see `raise_for_ct()`
#'     }
#'   }
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
    #' @field method (character) one or more URLs
    method = NULL,
    #' @field url (character) one or more URLs
    url = NULL,
    #' @field opts (character) one or more URLs
    opts = NULL,
    #' @field handle (character) one or more URLs
    handle = NULL,
    #' @field status_code (character) one or more URLs
    status_code = NULL,
    #' @field request_headers (character) one or more URLs
    request_headers = NULL,
    #' @field response_headers (character) one or more URLs
    response_headers = NULL,
    #' @field response_headers_all (character) one or more URLs
    response_headers_all = NULL,
    #' @field modified (character) one or more URLs
    modified = NULL,
    #' @field times (character) one or more URLs
    times = NULL,
    #' @field content (character) one or more URLs
    content = NULL,
    #' @field request (character) one or more URLs
    request = NULL,
    #' @field raise_for_ct for ct method (general)
    raise_for_ct = NULL,
    #' @field raise_for_ct_html for ct method (html)
    raise_for_ct_html = NULL,
    #' @field raise_for_ct_json for ct method (json)
    raise_for_ct_json = NULL,
    #' @field raise_for_ct_xml for ct method (xml)
    raise_for_ct_xml = NULL,

    #' @description print method for HttpResponse objects
    #' @param x self
    #' @param ... ignored
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

    #' @description Create a new HttpResponse object
    #' @param method (character) HTTP method
    #' @param url (character) A url, required
    #' @param opts (list) curl options
    #' @param handle A handle
    #' @param status_code (integer) status code
    #' @param request_headers (list) request headers, named list
    #' @param response_headers (list) response headers, named list
    #' @param response_headers_all (list) all response headers, including
    #' intermediate redirect headers, unnamed list of named lists
    #' @param modified (character) modified date
    #' @param times (vector) named vector
    #' @param content (raw) raw binary content response
    #' @param request request object, with all details
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

      self$raise_for_ct = private$raise_for_ct_user()
      self$raise_for_ct_html = private$raise_for_ct_factory(type = "html")
      self$raise_for_ct_json = private$raise_for_ct_factory(type = "json")
      self$raise_for_ct_xml = private$raise_for_ct_factory(type = "xml")
    },

    #' @description Parse the raw response content to text
    #' @param encoding (character) A character string describing the
    #' current encoding. If left as `NULL`, we attempt to guess the
    #' encoding. Passed to `from` parameter in `iconv`
    #' @param ... additional parameters passed on to `iconv` (options: sub,
    #' mark, toRaw). See `?iconv` for help
    #' @return character string
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
        try_raw2ch <- tryCatch(rawToChar(raw), error = function(e) e)
        rawout <- if (inherits(try_raw2ch, "error")) raw else rawToChar(raw)
        return(rawout)
      }
      if ("stream" %in% names(self$request)) {
        return(raw(0))
      }
      parse_content(self$content, encoding, ...)
    },

    #' @description Was status code less than or equal to 201
    #' @return boolean
    success = function() {
      self$status_code < 400L && self$status_code >= 200L
    },

    #' @description Get HTTP status code, message, and explanation
    #' @param verbose (logical) whether to get verbose http status description,
    #' default: `FALSE`
    #' @return object of class "http_code", a list with slots for status_code,
    #' message, and explanation
    status_http = function(verbose = FALSE) {
      httpcode::http_code(code = self$status_code, verbose = verbose)
    },

    #' @description Check HTTP status and stop with appropriate
    #' HTTP error code and message if >= 300. otherwise use \pkg{httpcode}.
    #' If you have `fauxpas` installed we use that.
    #' @return stop or warn with message
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
  ),

  private = list(
    raise_for_ct_user = function() {
      function(type, charset = NULL, behavior = "stop") {
        if (!type %in% mime::mimemap)
          stop("type not in allowed set, see ?mime::mimemap")
        type <- names(mime::mimemap[type == mime::mimemap])[1]
        private$raise_for_ct_factory(type)(
          charset = charset, behavior = behavior
        )
      }
    },
    raise_for_ct_factory = function(type) {
      function(charset = NULL, behavior = "stop") {
        behaviors <- c("stop", "warning")
        assert(behavior, "character")
        if (!behavior %in% behaviors)
          stop("'behavior' must be one of ", paste(behaviors, collapse = ", "))
        ctype <- mime::mimemap[[type]]
        rh <- self$response_headers
        names(rh) <- tolower(names(rh))
        if (is.null(rh$`content-type`))
          stop("content-type header is missing")
        rtype <- rh$`content-type`
        if (!is.null(charset)) {
          if (!grepl(";\\s?[A-Za-z0-9]+|;\\s?charset=[A-Za-z0-9]+", rtype)) {
            warning("no charset detected in response content-type",
              call. = FALSE)
          } else if (
            !grepl(ctype, rtype) ||
            !grepl(norm(charset), norm(rtype))
          ) {
            get(behavior)(sprintf("response content-type (%s) did not match expected type (%s)\nor character set (%s)", rtype, ctype, charset), call. = FALSE)
          }
        } else {
          if (!grepl(ctype, rtype)) {
            get(behavior)(sprintf("response content-type (%s) did not match expected type (%s)",
              rtype, ctype), call. = FALSE)
          }
        }
      }
    }
  )
)

# remove spaces; lowercase everything
norm <- function(x) {
  x <- gsub("\\s", "", x)
  x <- tolower(x)
  return(x)
}

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
