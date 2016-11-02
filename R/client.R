#' Base client object
#'
#' @export
#' @param url (character) A url
#' @param opts (list) curl options
#' @param handle A handle
#' @details
#' \strong{Methods}
#'   \describe{
#'     \item{\code{get(path, query, ...)}}{
#'       Make a GET request
#'     }
#'     \item{\code{post(path, query, body, ...)}}{
#'       Make a POST request
#'     }
#'     \item{\code{put(path, query, body, ...)}}{
#'       Make a PUT request
#'     }
#'     \item{\code{patch(path, query, body, ...)}}{
#'       Make a PATCH request
#'     }
#'     \item{\code{delete(path, query, body, ...)}}{
#'       Make a DELETE request
#'     }
#'     \item{\code{head(path, query, ...)}}{
#'       Make a HEAD request
#'     }
#'     \item{\code{options(path, query, ...)}}{
#'       Make an OPTIONS request
#'     }
#'   }
#' @format NULL
#' @usage NULL
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
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
#' }
HttpClient <- R6::R6Class(
  'HttpClient',
  public = list(
    url = NULL,
    opts = NULL,
    handle = NULL,

    print = function(x, ...) {
      cat("<crul connection> ", sep = "\n")
      cat(paste0("  url: ", self$url), sep = "\n")
      cat("  options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        cat(sprintf("  %s: %s", names(self$opts)[i], self$opts[[i]]), sep = "\n")
      }
      cat("  params: ", sep = "\n")
      if (!is.null(self$status_code)) cat(paste0("  status: ", self$status_code), sep = "\n")
      invisible(self)
    },

    initialize = function(url, opts, handle) {
      if (!missing(url)) self$url <- url
      if (!missing(opts)) self$opts <- opts
      if (!missing(handle)) self$handle <- handle
      if (is.null(self$url) && is.null(self$handle)) stop("need one of url or handle", call. = FALSE)
    },

    get = function(path = NULL, query = list(), ...) {
      url <- make_url(self$url, path, query)
      rr <- list(
        url = url,
        method = "get",
        options = list(httpget = TRUE),
        headers = list(),
        useragent = make_ua()
      )
      private$make_request(rr)
    },

    post = function(path = NULL, query = list(), body = NULL, ...) {
      url <- make_url(self$url, path, query)
      opts <- list(post = TRUE)
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "post",
        options = opts,
        headers = list(),
        fields = body,
        useragent = make_ua()
      )
      private$make_request(rr)
    },

    put = function(path = NULL, query = list(), body = NULL, ...) {
      url <- make_url(self$url, path, query)
      opts <- list(customrequest = "PUT")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "put",
        options = opts,
        headers = list(),
        fields = body,
        useragent = make_ua()
      )
      private$make_request(rr)
    },

    patch = function(path = NULL, query = list(), body = NULL, ...) {
      url <- make_url(self$url, path, query)
      opts <- list(customrequest = "PATCH")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "patch",
        options = opts,
        headers = list(),
        fields = body,
        useragent = make_ua()
      )
      private$make_request(rr)
    },

    delete = function(path = NULL, query = list(), body = NULL, ...) {
      url <- make_url(self$url, path, query)
      opts <- list(customrequest = "DELETE")
      if (is.null(body)) {
        opts$postfields <- raw(0)
        opts$postfieldsize <- 0
      }
      rr <- list(
        url = url,
        method = "delete",
        options = opts,
        headers = list(),
        fields = body,
        useragent = make_ua()
      )
      private$make_request(rr)
    },

    head = function(path = NULL, ...) {
      url <- make_url(self$url, path, NULL)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = opts,
        headers = list(),
        useragent = make_ua()
      )
      private$make_request(rr)
    }
  ),

  private = list(
    request = NULL,

    make_request = function(opts) {
      h <- curl::new_handle()
      curl::handle_setopt(h, .list = opts$options)
      if (!is.null(opts$fields)) {
        curl::handle_setform(h, .list = opts$fields)
      }
      curl::handle_setheaders(h, .list = opts$headers)
      on.exit(curl::handle_reset(h), add = TRUE)
      resp <- curl::curl_fetch_memory(opts$url, h)

      HttpResponse$new(
        method = opts$method,
        url = resp$url,
        status_code = resp$status_code,
        request_headers = c(useragent = opts$useragent, opts$headers),
        response_headers = curl::parse_headers(rawToChar(resp$headers)),
        modified = resp$modified,
        times = resp$times,
        content = resp$content,
        handle = h,
        request = opts
      )
    }
  )
)
