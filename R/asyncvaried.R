#' Async client for different request types
#'
#' @export
#' @param ...,.list Any number of objects of class \code{\link{HttpRequest}},
#' must supply inputs to one of these parameters, but not both
#' @family async
#' @return An object of class \code{AsyncVaried} with variables and methods
#' @details
#' \strong{Methods}
#'   \describe{
#'     \item{\code{request()}}{
#'       execute asynchronous requests
#'     }
#'     \item{\code{requests()}}{
#'       list requests
#'     }
#'     \item{\code{parse(encoding = "UTF-8")}}{
#'       parse content
#'     }
#'     \item{\code{status_code()}}{
#'       (integer) HTTP status codes
#'     }
#'     \item{\code{status()}}{
#'       (list) HTTP status objects
#'     }
#'     \item{\code{content()}}{
#'       raw content
#'     }
#'     \item{\code{times()}}{
#'       curl request times
#'     }
#'   }
#'
#' @format NULL
#' @usage NULL
#' @examples \dontrun{
#' # pass in requests via ...
#' req1 <- HttpRequest$new(
#'   url = "https://httpbin.org/get",
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )$get()
#' req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post()
#' out <- AsyncVaried$new(req1, req2)
#' out$request()
#' out$status()
#' out$status_code()
#' out$content()
#' out$times()
#' out$parse()
#' out$responses()
#'
#' # pass in requests in a list via .list param
#' reqlist <- list(
#'   HttpRequest$new(url = "https://httpbin.org/get")$get(),
#'   HttpRequest$new(url = "https://httpbin.org/post")$post(),
#'   HttpRequest$new(url = "https://httpbin.org/put")$put(),
#'   HttpRequest$new(url = "https://httpbin.org/delete")$delete(),
#'   HttpRequest$new(url = "https://httpbin.org/get?g=5")$get(),
#'   HttpRequest$new(
#'     url = "https://httpbin.org/post")$post(body = list(y = 9)),
#'   HttpRequest$new(
#'     url = "https://httpbin.org/get")$get(query = list(hello = "world"))
#' )
#'
#' out <- AsyncVaried$new(.list = reqlist)
#' out$request()
#' out$status()
#' out$status_code()
#' out$content()
#' out$times()
#' out$parse()
#' }
AsyncVaried <- R6::R6Class(
  'AsyncVaried',
  public = list(
    print = function(x, ...) {
      cat("<crul async varied connection> ", sep = "\n")
      cat("  requests: ", sep = "\n")
      for (i in seq_along(private$reqs)) {
        cat(sprintf("   %s: %s",
                    private$reqs[[i]]$payload$method,
                    private$reqs[[i]]$url), "\n")
      }
      invisible(self)
    },

    initialize = function(..., .list = list()) {
      if (length(.list)) {
        private$reqs <- .list
      } else {
        private$reqs <- list(...)
      }
      if (length(private$reqs) == 0) {
        stop("must pass in at least one request", call. = FALSE)
      }
      if (
        any(vapply(private$reqs, function(x) class(x)[1], "") != "HttpRequest")
      ) {
        stop("all inputs must be of class 'HttpRequest'", call. = FALSE)
      }
    },

    request = function() {
      private$output <- private$async_request(private$reqs)
    },

    responses = function() {
      private$output
    },

    requests = function() {
      private$reqs
    },

    parse = function(encoding = "UTF-8") {
      vapply(private$output, function(z) z$parse(encoding = encoding), "")
    },

    status_code = function() {
      vapply(private$output, function(z) z$status_code, 1)
    },

    status = function() {
      lapply(private$output, function(z) z$status_http())
    },

    content = function() {
      lapply(private$output, function(z) z$content)
    },

    times = function() {
      lapply(private$output, function(z) z$times)
    }
  ),

  private = list(
    reqs = NULL,
    output = NULL,
    reqq = NULL,

    async_request = function(reqs) {
      crulpool <- curl::new_pool()

      multi_res <- vector("list", length(reqs))
      suc_cess <- function(res) multi_res <<- c(multi_res, list(res))

      lapply(reqs, function(w) {
        w <- w$payload
        # setup handle
        # h <- curl::new_handle(url = w$url$url)
        h <- w$url$handle
        curl::handle_setopt(h, .list = w$options)
        if (!is.null(w$fields)) {
          curl::handle_setform(h, .list = w$fields)
        }
        curl::handle_setheaders(h, .list = w$headers)
        # add to pool
        curl::multi_add(h, done = suc_cess, pool = crulpool)
      })

      # run all requests
      curl::multi_run(pool = crulpool)
      remain <- curl::multi_list(crulpool)
      if (length(remain)) lapply(remain, curl::multi_cancel)
      multi_res <- ccp(multi_res)

      Map(function(z, b) {
        HttpResponse$new(
          method = b$payload$method,
          url = z$url,
          status_code = z$status_code,
          request_headers = c(useragent = b$payload$options$useragent, b$headers),
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
