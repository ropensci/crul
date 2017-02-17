#' HTTP request object
#'
#' @export
#'
#' @param url (character) A url. One of \code{url} or \code{handle} required.
#' @param opts (list) curl options
#' @param proxies an object of class \code{proxy}, as returned from the
#' \code{\link{proxy}} function. Supports one proxy for now
#' @param method (character) HTTP method: head, get, post, put, patch,
#' delete, options
#' @param headers (list) a named list of headers
#' @param handle A handle, see \code{\link{handle}}
#'
#' @seealso \code{\link{post-requests}}, \code{\link{http-headers}},
#' \code{\link{writing-options}}
#'
#' @details This R6 class doesn't do actual HTTP requests as does
#' \code{\link{HttpClient}} - but is rather for building requests
#' to use for async HTTP requests in either \code{\link{Async}}
#' or \code{\link{AsyncVaried}}
#'
#' @format NULL
#' @usage NULL
#'
#' @examples
#' (x <- HttpRequest$new(url = "https://httpbin.org")$get())
#' x$method
#' x$url
#' x$payload
#'
#' (x <- HttpRequest$new(url = "http://localhost:9000/post"))
#' x$post(body = list(foo = "bar"))
HttpRequest <- R6::R6Class(
  'HttpRequest',
  public = list(
    url = NULL,
    method = NULL,
    opts = list(),
    proxies = list(),
    headers = list(),
    handle = NULL,
    payload = NULL,

    print = function(x, ...) {
      cat("<crul http request> ", sep = "\n")
      cat(paste0("  url: ", if (is.null(self$url)) self$handle$url else self$url), sep = "\n")
      cat("  options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        cat(sprintf("    %s: %s", names(self$opts)[i],
                    self$opts[[i]]), sep = "\n")
      }
      cat("  proxies: ", sep = "\n")
      if (length(self$proxies)) cat(paste("    -", purl(self$proxies)), sep = "\n")
      cat("  headers: ", sep = "\n")
      for (i in seq_along(self$headers)) {
        cat(sprintf("    %s: %s", names(self$headers)[i],
                    self$headers[[i]]), sep = "\n")
      }
      invisible(self)
    },

    initialize = function(url, method = "get", opts, proxies, headers, handle) {
      if (!missing(url)) self$url <- url
      if (!missing(url)) self$method <- method
      if (!missing(opts)) self$opts <- opts
      if (!missing(proxies)) {
        if (!inherits(proxies, "proxy")) {
          stop("proxies input must be of class proxy", call. = FALSE)
        }
        self$proxies <- proxies
      }
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
        options = list(
          httpget = TRUE,
          useragent = make_ua()
        ),
        headers = self$headers
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
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
      rr <- list(
        url = url,
        method = "post",
        options = as.list(c(
          opts$opts,
          useragent = make_ua()
        )),
        headers = c(self$headers, opts$type),
        fields = opts$fields
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    put = function(path = NULL, query = list(), body = NULL, disk = NULL,
                   stream = NULL, encode = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- list(customrequest = "PUT")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "put",
        options = c(
          opts,
          useragent = make_ua()
        ),
        headers = self$headers,
        fields = body
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    patch = function(path = NULL, query = list(), body = NULL, disk = NULL,
                     stream = NULL, encode = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- list(customrequest = "PATCH")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "patch",
        options = c(
          opts,
          useragent = make_ua()
        ),
        headers = self$headers,
        fields = body
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    delete = function(path = NULL, query = list(), body = NULL, disk = NULL,
                      stream = NULL, encode = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, query)
      opts <- list(customrequest = "DELETE")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "delete",
        options = c(
          opts,
          useragent = make_ua()
        ),
        headers = self$headers,
        fields = body
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    },

    head = function(path = NULL, disk = NULL, stream = NULL, ...) {
      curl_opts_check(...)
      url <- make_url_async(self$url, self$handle, path, NULL)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = c(
          opts,
          useragent = make_ua()
        ),
        headers = self$headers
      )
      rr$options <- utils::modifyList(rr$options,
                                      c(self$opts, self$proxies, ...))
      rr$disk <- disk
      rr$stream <- stream
      self$payload <- rr
      return(self)
    }
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
