#' HTTP client
#'
#' @keywords internal
#' @param url A url
#' @param opts curl options
#' @param handle A handle
#' @details
#' \strong{Methods}
#'   \describe{
#'     \item{\code{register_stub(stub)}}{
#'       Register a stub
#'     }
#'   }
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$url
#' (res <- x$get('get'))
#' res$content
#' res$response_headers
#' res$parse()
#'
#' (res2 <- x$get('get', query = list(hello = "world")))
#' res2$parse()
#' library("jsonlite")
#' jsonlite::fromJSON(res2$parse())
#'
#' # post request
#' (res3 <- x$post('post', body = list(hello = "world")))
#'
#' ## empty body request
#' x$post('post')
#' }
HttpClient <- R6::R6Class(
  'HttpClient',
  public = list(
    url = NULL,
    opts = NULL,
    handle = NULL,
    status_code = NULL,
    headers = NULL,
    modified = NULL,
    times = NULL,
    content = NULL,

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
    },

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
      self$make_request(rr)
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
      self$make_request(rr)
    }
  ),

  private = list(
    request = NULL
  )
)

make_url <- function(url, path, query) {
  if (!is.null(path)) {
    urltools::path(url) <- path
  }

  if (length(query)) {
    for (i in seq_along(query)) {
      url <- urltools::param_set(url, names(query)[i], query[[i]])
    }
  }

  return(url)
}
