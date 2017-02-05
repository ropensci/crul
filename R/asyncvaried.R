#' Async client for different request types
#'
#' @export
#' @examples \dontrun{
#' # 1st request - GET
#' (req1 <- HttpClient2$new(
#'   url = "http://localhost:9000/get"
#' ))
#' req1$get()
#'
#' # 2nd request = POST
#' req2 <- HttpClient2$new(
#'   url = "http://localhost:9000/post"
#' )
#' req2$post()
#'
#' # build async client
#' (manyreq <- AsyncVaried$new(req1, req2))
#' manyreq$request()
#' manyreq$parse()
#'
#' # all in one call
#' req1 <- HttpClient2$new(url = "http://localhost:9000/get")$get()
#' req2 <- HttpClient2$new(url = "http://localhost:9000/post")$post()
#' out <- AsyncVaried$new(req1, req2)
#' out$request()
#' out$status()
#' out$status_code()
#' out$content()
#' out$times()
#' out$parse()
#'
#' # lots of calls
#' reqlist <- list(
#'   HttpClient2$new(url = "http://localhost:9000/get")$get(),
#'   HttpClient2$new(url = "http://localhost:9000/post")$post(),
#'   HttpClient2$new(url = "http://localhost:9000/put")$put(),
#'   HttpClient2$new(url = "http://localhost:9000/delete")$delete(),
#'   HttpClient2$new(url = "http://localhost:9000/get?g=5")$get(),
#'   HttpClient2$new(url = "http://localhost:9000/post")$post(body = list(y = 9)),
#'   HttpClient2$new(url = "http://localhost:9000/get")$get(query = list(hello = "world"))
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
    reqs = NULL,
    output = NULL,

    print = function(x, ...) {
      cat("<crul async connection> ", sep = "\n")
      cat("  requests: ", sep = "\n")
      for (i in seq_along(self$reqs)) {
        cat("   ", self$reqs[[i]]$url, "\n")
      }
      invisible(self)
    },

    initialize = function(..., .list = list()) {
      if (length(.list)) {
        self$reqs <- .list
      } else {
        self$reqs <- list(...)
      }
    },

    request = function() {
      self$output <- private$async_request(self$reqs)
    },

    parse = function() {
      vapply(self$output, function(z) z$parse("UTF-8"), "")
    },

    status_code = function() {
      vapply(self$output, function(z) z$status_code, 1)
    },

    status = function() {
      lapply(self$output, function(z) z$status_http())
    },

    content = function() {
      lapply(self$output, function(z) z$content)
    },

    times = function() {
      lapply(self$output, function(z) z$times)
    }
  ),

  private = list(
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
          method = b$method,
          url = z$url,
          status_code = z$status_code,
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

# async <- function(...) {
#   tmp <- AsyncClient2$new(...)
#   tmp$request()
#   tmp
# }
