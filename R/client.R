#' HTTP client
#'
#' @export
#' @template args
#' @details
#' **Methods**
#'   \describe{
#'     \item{`get(path, query, disk, stream, ...)`}{
#'       Make a GET request
#'     }
#'     \item{`post(path, query, body, disk, stream, ...)`}{
#'       Make a POST request
#'     }
#'     \item{`put(path, query, body, disk, stream, ...)`}{
#'       Make a PUT request
#'     }
#'     \item{`patch(path, query, body, disk, stream, ...)`}{
#'       Make a PATCH request
#'     }
#'     \item{`delete(path, query, body, disk, stream, ...)`}{
#'       Make a DELETE request
#'     }
#'     \item{`head(path, query, ...)`}{
#'       Make a HEAD request
#'     }
#'   }
#'
#' @format NULL
#' @usage NULL
#' @details Possible parameters (not all are allowed in each HTTP verb):
#' \itemize{
#'  \item path - URL path, appended to the base URL
#'  \item query - query terms, as a named list
#'  \item body - body as an R list
#'  \item encode - one of form, multipart, json, or raw
#'  \item disk - a path to write to. if NULL (default), memory used.
#'  See [curl::curl_fetch_disk()] for help.
#'  \item stream - an R function to determine how to stream data. if
#'  NULL (default), memory used. See [curl::curl_fetch_stream()]
#'  for help
#'  \item ... curl options, only those in the acceptable set from
#'  [curl::curl_options()] except the following: httpget, httppost,
#'  post, postfields, postfieldsize, and customrequest
#' }
#'
#' @section handles:
#' curl handles are re-used on the level of the connection object, that is,
#' each `HttpClient` object is separate from one another so as to better
#' separate connections.
#'
#' @seealso [post-requests], [delete-requests], [http-headers],
#' [writing-options], [cookies]
#'
#' @examples
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' x$url
#' (res_get1 <- x$get('get'))
#' res_get1$content
#' res_get1$response_headers
#' res_get1$parse()
#'
#' (res_get2 <- x$get('get', query = list(hello = "world")))
#' res_get2$parse()
#' library("jsonlite")
#' jsonlite::fromJSON(res_get2$parse())
#'
#' # post request
#' (res_post <- x$post('post', body = list(hello = "world")))
#'
#' ## empty body request
#' x$post('post')
#'
#' # put request
#' (res_put <- x$put('put'))
#'
#' # delete request
#' (res_delete <- x$delete('delete'))
#'
#' # patch request
#' (res_patch <- x$patch('patch'))
#'
#' # head request
#' (res_head <- x$head())
#'
#' # query params are URL encoded for you, so DO NOT do it yourself
#' ## if you url encode yourself, it gets double encoded, and that's bad
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' res <- x$get("get", query = list(a = 'hello world'))

HttpClient <- R6::R6Class(
  'HttpClient',
  public = list(
    url = NULL,
    opts = list(),
    proxies = list(),
    auth = list(),
    headers = list(),
    handle = NULL,

    print = function(x, ...) {
      cat("<crul connection> ", sep = "\n")
      cat(paste0("  url: ",
                 if (is.null(self$url)) self$handle$url else self$url),
          sep = "\n")
      cat("  curl options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        cat(sprintf("    %s: %s", names(self$opts)[i],
                    self$opts[[i]]), sep = "\n")
      }
      cat("  proxies: ", sep = "\n")
      if (length(self$proxies)) cat(paste("    -", purl(self$proxies)),
                                    sep = "\n")
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
      invisible(self)
    },

    initialize = function(url, opts, proxies, auth, headers, handle) {
      private$crul_h_pool <- new.env(hash = TRUE, parent = emptyenv())
      if (!missing(url)) self$url <- url
      if (!missing(opts)) self$opts <- opts
      if (!missing(proxies)) {
        if (!inherits(proxies, "proxy")) {
          stop("proxies input must be of class proxy", call. = FALSE)
        }
        self$proxies <- proxies
      }
      if (!missing(auth)) self$auth <- auth
      if (!missing(headers)) self$headers <- headers
      if (!missing(handle)) self$handle <- handle
      if (is.null(self$url) && is.null(self$handle)) {
        stop("need one of url or handle", call. = FALSE)
      }
    },

    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      rr <- list(
        url = url,
        method = "get",
        options = ccp(list(httpget = TRUE, cainfo = find_cert_bundle())),
        headers = def_head()
      )
      rr$headers <- norm_headers(rr$headers, self$headers)
      rr$options <- utils::modifyList(
        rr$options, c(self$opts, self$proxies, self$auth, ...))
      rr$options <- curl_opts_fil(rr$options)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    post = function(path = NULL, query = list(), body = NULL, disk = NULL,
                    stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("post", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    put = function(path = NULL, query = list(), body = NULL, disk = NULL,
                   stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("put", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    patch = function(path = NULL, query = list(), body = NULL, disk = NULL,
                     stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("patch", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    delete = function(path = NULL, query = list(), body = NULL, disk = NULL,
                      stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("delete", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    head = function(path = NULL, query = list(), ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = ccp(c(opts, cainfo = find_cert_bundle())),
        headers = self$headers
      )
      rr$options <- utils::modifyList(
        rr$options,
        c(self$opts, self$proxies, ...))
      private$make_request(rr)
    },

    handle_pop = function() {
      name <- handle_make(self$url)
      if (exists(name, envir = private$crul_h_pool)) {
        rm(list = name, envir = private$crul_h_pool)
      }
    }
  ),

  private = list(
    request = NULL,
    crul_h_pool = NULL,
    handle_find = function(x) {
      z <- handle_make(x)
      if (exists(z, private$crul_h_pool)) {
        handle <- private$crul_h_pool[[z]]
      } else {
        handle <- handle(z)
        private$crul_h_pool[[z]] <- handle
      }
      return(handle)
    },

    make_url = function(url = NULL, handle = NULL, path, query) {
      if (!is.null(handle)) {
        url <- handle$url
      } else {
        handle <- private$handle_find(url)
        url <- handle$url
      }
      if (!is.null(path)) {
        urltools::path(url) <- path
      }
      url <- gsub("\\s", "%20", url)
      url <- add_query(query, url)
      return(list(url = url, handle = handle$handle))
    },

    make_request = function(opts) {
      if (xor(!is.null(opts$disk), !is.null(opts$stream))) {
        if (!is.null(opts$disk) && !is.null(opts$stream)) {
          stop("disk and stream can not be used together", call. = FALSE)
        }
      }
      curl::handle_setopt(opts$url$handle, .list = opts$options)
      if (!is.null(opts$fields)) {
        curl::handle_setform(opts$url$handle, .list = opts$fields)
      }
      curl::handle_setheaders(opts$url$handle, .list = opts$headers)
      on.exit(curl::handle_reset(opts$url$handle), add = TRUE)

      if (crul_opts$mock) {
        check_for_package("webmockr")
        adap <- webmockr::CrulAdapter$new()
        return(adap$handle_request(opts))
      } else {
        resp <- crul_fetch(opts)
      }

      # build response
      HttpResponse$new(
        method = opts$method,
        url = resp$url,
        status_code = resp$status_code,
        request_headers = c(useragent = opts$options$useragent, opts$headers),
        response_headers = {
          if (grepl("^ftp://", resp$url)) {
            list()
          } else {
            hh <- rawToChar(resp$headers %||% raw(0))
            if (is.null(hh) || nchar(hh) == 0) {
              list()
            } else {
              headers_parse(curl::parse_headers(hh))
            }
          }
        },
        modified = resp$modified,
        times = resp$times,
        content = resp$content,
        handle = opts$url$handle,
        request = opts
      )
    }
  )
)
