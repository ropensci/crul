#' @title HTTP request object
#' @description Create HTTP requests
#'
#' @export
#' @family async
#' @template args
#' @template r6
#' @param path URL path, appended to the base URL
#' @param query query terms, as a named list
#' @param body body as an R list
#' @param encode one of form, multipart, json, or raw
#' @param disk a path to write to. if NULL (default), memory used.
#' See [curl::curl_fetch_disk()] for help.
#' @param stream an R function to determine how to stream data. if
#' NULL (default), memory used. See [curl::curl_fetch_stream()]
#' for help
#' @param ... curl options, only those in the acceptable set from
#' [curl::curl_options()] except the following: httpget, httppost, post,
#' postfields, postfieldsize, and customrequest
#' @seealso [http-headers], [writing-options]
#' @details This R6 class doesn't do actual HTTP requests as does
#' [HttpClient()] - it is for building requests to use for async HTTP
#' requests in [AsyncVaried()]
#'
#' Note that you can access HTTP verbs after creating an `HttpRequest`
#' object, just as you can with `HttpClient`. See examples for usage.
#'
#' Also note that when you call HTTP verbs on a `HttpRequest` object you
#' don't need to assign the new object to a variable as the new details
#' you've added are added to the object itself.
#'
#' See [HttpClient()] for information on parameters.
#'
#' @examples \dontrun{
#' x <- HttpRequest$new(url = "https://hb.opencpu.org/get")
#' ## note here how the HTTP method is shown on the first line to the right
#' x$get()
#'
#' ## assign to a new object to keep the output
#' z <- x$get()
#' ### get the HTTP method
#' z$method()
#'
#' (x <- HttpRequest$new(url = "https://hb.opencpu.org/get")$get())
#' x$url
#' x$payload
#'
#' (x <- HttpRequest$new(url = "https://hb.opencpu.org/post"))
#' x$post(body = list(foo = "bar"))
#'
#' HttpRequest$new(
#'   url = "https://hb.opencpu.org/get",
#'   headers = list(
#'     `Content-Type` = "application/json"
#'   )
#' )
#'
#' # retry
#' (x <- HttpRequest$new(url = "https://hb.opencpu.org/post"))
#' x$retry("post", body = list(foo = "bar"))
#' }
HttpRequest <- R6::R6Class(
  'HttpRequest',
  public = list(
    #' @field url (character) a url
    url = NULL,
    #' @field opts (list) named list of curl options
    opts = list(),
    #' @field proxies a [proxy()] object
    proxies = list(),
    #' @field auth an [auth()] object
    auth = list(),
    #' @field headers (list) named list of headers, see [http-headers]
    headers = list(),
    #' @field handle a [handle()]
    handle = NULL,
    #' @field progress only supports `httr::progress()`, see [progress]
    progress = NULL,
    #' @field payload resulting payload after request
    payload = NULL,

    #' @description print method for `HttpRequest` objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      retry_note <- if ("retry_options" %in% names(self$payload)) " (retry)" else ""
      cat(paste0("<crul http request> ", self$method(), retry_note), sep = "\n")
      cat(paste0("  url: ",
        self$payload$url$url %||% self$handle$url %||% self$url), sep = "\n")
      cat("  curl options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        z <- if (inherits(self$opts[[i]], "function")) "<function>" else self$opts[[i]]
        cat(sprintf("    %s: %s", names(self$opts)[i], z), sep = "\n")
      }
      cat("  proxies: ", sep = "\n")
      if (length(self$proxies)) cat(paste("    -",
                                          purl(self$proxies)), sep = "\n")
      cat("  auth: ", sep = "\n")
      if (length(self$auth$userpwd)) {
        cat(paste("    -", self$auth$userpwd), sep = "\n")
        cat(paste("    - type: ", self$auth$httpauth), sep = "\n")
      }
      cat("  headers: ", sep = "\n")
      for (i in seq_along(self$headers)) {
        cat(sprintf("    %s: %s", names(self$headers)[i],
                    self$headers[[i]]), sep = "\n")
      }
      cat(paste0("  progress: ", !is.null(self$progress)), sep = "\n")
      invisible(self)
    },

    #' @description Create a new `HttpRequest` object
    #' @param urls (character) one or more URLs
    #' @param opts any curl options
    #' @param proxies a [proxy()] object
    #' @param auth an [auth()] object
    #' @param headers named list of headers, see [http-headers]
    #' @param handle a [handle()]
    #' @param progress only supports `httr::progress()`, see [progress]
    #' @return A new `HttpRequest` object
    initialize = function(url, opts, proxies, auth, headers, handle, progress) {
      if (!missing(url)) self$url <- url

      # curl options: check for set_opts first
      if (!is.null(crul_opts$opts)) self$opts <- crul_opts$opts
      if (!missing(opts)) self$opts <- opts %||% list()

      # proxy: check for set_proxy first
      if (!is.null(crul_opts$proxies)) self$proxies <- crul_opts$proxies
      if (!missing(proxies)) {
        if (!inherits(proxies, "proxy") && !is.null(proxies)) {
          stop("proxies input must be of class proxy", call. = FALSE)
        }
        self$proxies <- proxies %||% list()
      }

      # auth: check for set_auth first
      if (!is.null(crul_opts$auth)) self$auth <- crul_opts$auth
      if (!missing(auth)) self$auth <- auth %||% list()

      # progress
      if (!missing(progress)) {
        assert(progress, "request")
        self$progress <- progress$options
      }

      # headers: check for set_headers first
      if (!is.null(crul_opts$headers)) self$headers <- crul_opts$headers
      if (!missing(headers)) self$headers <- headers %||% list()

      if (!missing(handle)) self$handle <- handle
      if (is.null(self$url) && is.null(self$handle)) {
        stop("need one of url or handle", call. = FALSE)
      }
    },

    #' @description Define a GET request
    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      rr <- list(
        url = url,
        method = "get",
        options = ccp(list(httpget = TRUE)),
        headers = def_head()
      )
      rr$headers <- norm_headers(rr$headers, self$headers)
      rr$options <- utils::modifyList(
        rr$options, c(self$opts, self$proxies, self$auth, self$progress, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    #' @description Define a POST request
    post = function(path = NULL, query = list(), body = NULL, disk = NULL,
                    stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("post", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    #' @description Define a PUT request
    put = function(path = NULL, query = list(), body = NULL, disk = NULL,
                   stream = NULL, encode =  "multipart", ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("put", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    #' @description Define a PATCH request
    patch = function(path = NULL, query = list(), body = NULL, disk = NULL,
                     stream = NULL, encode =  "multipart", ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("patch", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    #' @description Define a DELETE request
    delete = function(path = NULL, query = list(), body = NULL, disk = NULL,
                      stream = NULL, encode =  "multipart", ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("delete", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    #' @description Define a HEAD request
    head = function(path = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, NULL)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = ccp(opts),
        headers = self$headers
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      self$payload <- rr
      return(self)
    },

    #' @description Use an arbitrary HTTP verb supported on this class
    #' Supported verbs: get, post, put, patch, delete, head
    #' @param verb an HTTP verb supported on this class: get,
    #' post, put, patch, delete, head. Also supports retry.
    #' @examples
    #' z <- HttpRequest$new(url = "https://hb.opencpu.org/get")
    #' res <- z$verb('get', query = list(hello = "world"))
    #' res$payload
    verb = function(verb, ...) {
      stopifnot(is.character(verb), length(verb) > 0)
      verbs <- c('get', 'post', 'put', 'patch', 'delete', 'head')
      if (!tolower(verb) %in% verbs) stop("'verb' must be one of: ", paste0(verbs, collapse = ", "))
      verbFunc <- self[[tolower(verb)]]
      stopifnot(is.function(verbFunc))
      verbFunc(...)
    },

    #' @description Define a RETRY request
    #' @param verb an HTTP verb supported on this class: get,
    #' post, put, patch, delete, head. Also supports retry.
    #' @param times the maximum number of times to retry. Set to `Inf` to
    #' not stop retrying due to exhausting the number of attempts.
    #' @param pause_base,pause_cap,pause_min basis, maximum, and minimum for
    #' calculating wait time for retry. Wait time is calculated according to the
    #' exponential backoff with full jitter algorithm. Specifically, wait time is
    #' chosen randomly between `pause_min` and the lesser of `pause_base * 2` and
    #' `pause_cap`, with `pause_base` doubling on each subsequent retry attempt.
    #' Use `pause_cap = Inf` to not terminate retrying due to cap of wait time
    #' reached.
    #' @param terminate_on,retry_only_on a vector of HTTP status codes. For
    #' `terminate_on`, the status codes for which to terminate retrying, and for
    #' `retry_only_on`, the status codes for which to retry the request.
    #' @param onwait a callback function if the request will be retried and
    #' a wait time is being applied. The function will be passed two parameters,
    #' the response object from the failed request, and the wait time in seconds.
    #' Note that the time spent in the function effectively adds to the wait time,
    #' so it should be kept simple.
    retry = function(verb, ..., pause_base = 1, pause_cap = 60, pause_min = 1, times = 3,
                     terminate_on = NULL, retry_only_on = NULL,
                     onwait = NULL) {
      stopifnot(is.character(verb), length(verb) > 0)
      verbs <- c('get', 'post', 'put', 'patch', 'delete', 'head')
      if (!tolower(verb) %in% verbs) stop("'verb' must be one of: ", paste0(verbs, collapse = ", "))
      verbFunc <- self[[tolower(verb)]]
      stopifnot(is.function(verbFunc))
      stopifnot(is.null(onwait) || is.function(onwait))
      tmp <- verbFunc(...)
      tmp$payload$retry_options <- list(pause_base = pause_base, pause_cap = pause_cap,
        pause_min = pause_min, times = times, terminate_on = terminate_on,
        retry_only_on = retry_only_on, onwait = onwait)
      return(tmp)
    },

    #' @description Get the HTTP method (if defined)
    #' @return (character) the HTTP method
    method = function() self$payload$method
  )
)

make_url_async <- function(url = NULL, handle = NULL, path, query) {
  if (!is.null(handle)) {
    url <- handle$url
  }

  if (!is.null(path)) {
    urltools::path(url) <- path
  }

  url <- gsub("\\s", "%20", url)
  url <- add_query(query, url)

  if (!is.null(handle)) {
    curl::handle_setopt(handle$handle, url = url)
  } else {
    handle <- curl::new_handle(url = url)
  }

  return(list(url = url, handle = handle))
}
