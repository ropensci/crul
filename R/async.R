#' Simple async client
#'
#' @export
#' @examples \dontrun{
#' cc <- Async$new(
#'   urls = c(
#'     'http://localhost:9000/get',
#'     'http://localhost:9000/get?a=5',
#'     'http://localhost:9000/get?foo=bar'
#'   )
#' )
#' cc
#' (res <- cc$get())
#' res[[1]]
#' res[[1]]$url
#' res[[1]]$success()
#' res[[1]]$status_http()
#' res[[1]]$response_headers
#' res[[1]]$method
#' res[[1]]$content
#' res[[1]]$parse("UTF-8")
#'
#' lapply(res, function(z) z$parse("UTF-8"))
#' }
Async <- R6::R6Class(
  'Async',
  public = list(
    urls = NULL,

    print = function(x, ...) {
      cat("<crul async connection> ", sep = "\n")
      cat("  urls: ", sep = "\n")
      for (i in seq_along(self$urls)) {
        cat(paste0("   ", self$urls[[i]]), sep = "\n")
      }
      invisible(self)
    },

    initialize = function(urls) {
      if (!missing(urls)) self$urls <- urls
    },

    get = function(path = NULL, query = list(), ...) {
      curl_opts_check(...)
      reqs <- lapply(self$urls, function(z) {
        url <- make_url_async_simple(z)
        list(
          url = url,
          method = "get",
          options = list(
            httpget = TRUE,
            useragent = make_ua()
          ),
          headers = list()
        )
      })
      # reqs
      private$async_request(reqs)
    }
  ),

  private = list(
    request = NULL,

    async_request = function(reqs) {
      crulpool <- curl::new_pool()

      multi_res <- vector("list", length(reqs))
      suc_cess <- function(res) multi_res <<- c(multi_res, list(res))

      lapply(reqs, function(w) {
        # setup handle
        curl::handle_setopt(w$url$handle, .list = w$options)
        # add to pool
        curl::multi_add(w$url$handle, done = suc_cess, pool = crulpool)
      })

      # run all requests
      curl::multi_run(pool = crulpool)
      remain <- curl::multi_list(crulpool)
      if (length(remain)) lapply(remain, curl::multi_cancel)
      (multi_res <- ccp(multi_res))

      Map(function(z, b) {
        HttpResponse$new(
          method = b$method,
          url = z$url,
          status_code = z$status_code,
          #request_headers = c(useragent = opts$options$useragent, opts$headers),
          request_headers = list(),
          response_headers = {
            if (grepl("^ftp://", z$url)) {
              list()
            } else {
              headers_parse(curl::parse_headers(rawToChar(z$headers)))
            }
          },
          modified = z$modified,
          times = z$times,
          content = z$content,
          handle = b$handle,
          request = b
        )
      }, multi_res, reqs)
    }
  )
)

make_url_async_simple <- function(url) {
  list(handle = curl::new_handle(url = url))
}
