#' HTTP request object
#'
#' @export
#' @template args
#' @seealso [post-requests], [delete-requests],
#' [http-headers], [writing-options]
#'
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
#' **Methods**
#'   \describe{
#'     \item{`get(path, query, disk, stream, ...)`}{
#'       Define a GET request
#'     }
#'     \item{`post(path, query, body, disk, stream, ...)`}{
#'       Define a POST request
#'     }
#'     \item{`put(path, query, body, disk, stream, ...)`}{
#'       Define a PUT request
#'     }
#'     \item{`patch(path, query, body, disk, stream, ...)`}{
#'       Define a PATCH request
#'     }
#'     \item{`delete(path, query, body, disk, stream, ...)`}{
#'       Define a DELETE request
#'     }
#'     \item{`head(path, ...)`}{
#'       Define a HEAD request
#'     }
#'     \item{`method()`}{
#'       Get the HTTP method (if defined)
#'       - returns character string
#'     }
#'   }
#'
#' See [HttpClient()] for information on parameters.
#'
#' @format NULL
#' @usage NULL
#'
#' @examples \dontrun{
#' x <- HttpRequest$new(url = "https://httpbin.org/get")
#' ## note here how the HTTP method is shown on the first line to the right
#' x$get()
#'
#' ## assign to a new object to keep the output
#' z <- x$get()
#' ### get the HTTP method
#' z$method()
#'
#' (x <- HttpRequest$new(url = "https://httpbin.org/get")$get())
#' x$url
#' x$payload
#'
#' (x <- HttpRequest$new(url = "https://httpbin.org/post"))
#' x$post(body = list(foo = "bar"))
#'
#' HttpRequest$new(
#'   url = "https://httpbin.org/get",
#'   headers = list(
#'     `Content-Type` = "application/json"
#'   )
#' )
#' }
HttpRequest <- R6::R6Class(
  'HttpRequest',
  public = list(
    url = NULL,
    opts = list(),
    proxies = list(),
    auth = list(),
    headers = list(),
    handle = NULL,
    progress = NULL,
    payload = NULL,

    print = function(x, ...) {
      cat(paste0("<crul http request> ", self$method()), sep = "\n")
      cat(paste0("  url: ", if (is.null(self$url))
        self$handle$url else self$url), sep = "\n")
      cat("  curl options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        cat(sprintf("    %s: %s", names(self$opts)[i],
                    self$opts[[i]]), sep = "\n")
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

    initialize = function(url, opts, proxies, auth, headers, handle, progress) {
      if (!missing(url)) self$url <- url

      # curl options: check for set_opts first
      if (!is.null(crul_opts$opts)) self$opts <- crul_opts$opts
      if (!missing(opts)) self$opts <- opts

      # proxy: check for set_proxy first
      if (!is.null(crul_opts$proxies)) self$proxies <- crul_opts$proxies
      if (!missing(proxies)) {
        if (!inherits(proxies, "proxy")) {
          stop("proxies input must be of class proxy", call. = FALSE)
        }
        self$proxies <- proxies
      }

      # auth: check for set_auth first
      if (!is.null(crul_opts$auth)) self$auth <- crul_opts$auth
      if (!missing(auth)) self$auth <- auth

      # progress
      if (!missing(progress)) {
        assert(progress, "request")
        self$progress <- progress$options
      }

      # headers: check for set_headers first
      if (!is.null(crul_opts$headers)) self$headers <- crul_opts$headers
      if (!missing(headers)) self$headers <- headers
      
      if (!missing(handle)) self$handle <- handle
      if (is.null(self$url) && is.null(self$handle)) {
        stop("need one of url or handle", call. = FALSE)
      }
    },

    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      rr <- list(
        url = url,
        method = "get",
        options = ccp(list(httpget = TRUE, cainfo = find_cert_bundle())),
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

    head = function(path = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, NULL)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = ccp(c(opts, cainfo = find_cert_bundle())),
        headers = self$headers
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      self$payload <- rr
      return(self)
    },

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
    curl::handle_setopt(handle, url = url)
  } else {
    handle <- curl::new_handle(url = url)
  }

  return(list(url = url, handle = handle))
}
