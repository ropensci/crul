#' Async client for different request types
#'
#' @export
#' @param ...,.list Any number of objects of class [HttpRequest()],
#' must supply inputs to one of these parameters, but not both
#' @family async
#' @return An object of class `AsyncVaried` with variables and methods.
#' Responses are returned in the order they are passed in.
#' @details
#' **Methods**
#'   \describe{
#'     \item{`request()`}{
#'       Execute asynchronous requests
#'       - returns: nothing, responses stored inside object,
#'       though will print messages if you choose verbose output
#'     }
#'     \item{`requests()`}{
#'       list requests
#'       - returns: a list of `HttpRequest` objects, empty list before
#'       requests made
#'     }
#'     \item{`responses()`}{
#'       list responses
#'       - returns: a list of `HttpResponse` objects, empty list before
#'       requests made
#'     }
#'     \item{`parse(encoding = "UTF-8")`}{
#'       parse content
#'       - returns: character vector, empty character vector before
#'       requests made
#'     }
#'     \item{`status_code()`}{
#'       (integer) HTTP status codes
#'       - returns: numeric vector, empty numeric vector before
#'       requests made
#'     }
#'     \item{`status()`}{
#'       (list) HTTP status objects
#'       - returns: a list of `http_code` objects, empty list before
#'       requests made
#'     }
#'     \item{`content()`}{
#'       raw content
#'       - returns: raw list, empty list before requests made
#'     }
#'     \item{`times()`}{
#'       curl request times
#'       - returns: list of named numeric vectors, empty list before
#'       requests made
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
#'
#' # Create an AsyncVaried object
#' out <- AsyncVaried$new(req1, req2)
#'
#' # before you make requests, the methods return empty objects
#' out$status()
#' out$status_code()
#' out$content()
#' out$times()
#' out$parse()
#' out$responses()
#'
#' # make requests
#' out$request()
#'
#' # access various parts
#' ## http status objects
#' out$status()
#' ## status codes
#' out$status_code()
#' ## content (raw data)
#' out$content()
#' ## times
#' out$times()
#' ## parsed content
#' out$parse()
#' ## response objects
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
      private$output %||% list()
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
      multi_res <- list()

      make_request <- function(i) {
        w <- reqs[[i]]$payload
        h <- w$url$handle
        curl::handle_setopt(h, .list = w$options)
        if (!is.null(w$fields)) {
          curl::handle_setform(h, .list = w$fields)
        }
        curl::handle_setheaders(h, .list = w$headers)

        if (is.null(w$disk) && is.null(w$stream)) {
          curl::multi_add(
            handle = h,
            done = function(res) multi_res[[i]] <<- res,
            pool = crulpool
          )
        } else {
          if (!is.null(w$disk) && is.null(w$stream)) {
            stopifnot(inherits(w$disk, "character"))
            ff <- file(w$disk, open = "wb")
            curl::multi_add(
              handle = h,
              done = function(res) multi_res[[i]] <<- res,
              data = ff,
              pool = crulpool
            )
          } else if (is.null(w$disk) && !is.null(w$stream)) {
            stopifnot(is.function(w$stream))
            curl::multi_add(
              handle = h,
              done = function(res) multi_res[[i]] <<- res,
              data = w$stream,
              pool = crulpool
            )
          }
        }
      }

      for (i in seq_along(reqs)) make_request(i)

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
          request_headers = c(useragent = b$payload$options$useragent,
                              b$headers),
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
