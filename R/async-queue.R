#' @title AsyncQueue client
#' @description An AsyncQueue client
#' @export
#' @family async
#' @examples \dontrun{
#' req1 <- HttpRequest$new(
#'   url = "https://httpbin.org/get",
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )$get()
#' req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post()
#'
#' out <- AsyncQueue$new(req1, req2, bucket_size = 30)
#' out
#' out$request()
#' out$responses()
#' 
#' reqlist <- list(
#'   HttpRequest$new(url = "https://httpbin.org/get")$get(),
#'   HttpRequest$new(url = "https://httpbin.org/post")$post(),
#'   HttpRequest$new(url = "https://httpbin.org/put")$put(),
#'   HttpRequest$new(url = "https://httpbin.org/delete")$delete(),
#'   HttpRequest$new(url = "https://httpbin.org/get?g=5")$get(),
#'   HttpRequest$new(
#'     url = "https://httpbin.org/post")$post(body = list(y = 9)),
#'   HttpRequest$new(
#'     url = "https://httpbin.org/get")$get(query = list(hello = "world")),
#'   HttpRequest$new(url = "https://ropensci.org")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/about")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/packages")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/community")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/blog")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/careers")$get()
#' )
#' out <- AsyncQueue$new(.list = reqlist, bucket_size = 5, sleep = 3)
#' out <- AsyncQueue$new(.list = reqlist, bucket_size = 5)
#' out
#' out$bucket_size
#' out$requests()
#' out$.__enclos_env__$private$buckets
#' out$request()
#' out$responses()
#' }
AsyncQueue <- R6::R6Class(
  'AsyncQueue',
  inherit = AsyncVaried,
  public = list(
    #' @field bucket_size (integer) number of requests to send at once
    bucket_size = 5,
    #' @field sleep (integer) number of seconds to sleep between each bucket
    sleep = NULL,
    #' @field req_per_sec (integer) requests per second
    req_per_sec = NULL,
    #' @field req_per_hr (integer) requests per hour
    req_per_hr = NULL,

    #' @description print method for AsyncQueue objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      super$print()
      cat(paste0("  bucket_size: ", self$bucket_size), sep = "\n")
      cat(paste0("  sleep: ", self$sleep), sep = "\n")
      cat(paste0("  req_per_sec: ", self$req_per_sec), sep = "\n")
      cat(paste0("  req_per_hr: ", self$req_per_hr), sep = "\n")
      invisible(self)
    },

    #' @description Create a new `AsyncQueue` object
    #' @param ...,.list Any number of objects of class [HttpRequest()],
    #' must supply inputs to one of these parameters, but not both
    #' @param bucket_size (integer) number of requests to send at once.
    #' default: 5
    #' @param sleep (integer) seconds to sleep between buckets. default: 0
    #' @param req_per_sec (integer) maximum number of requests per second.
    #' if `NULL` (default), its ignored. NOT WORKING YET.
    #' @param req_per_hr (integer) maximum number of requests per hour. if `NULL`
    #' (default), its ignored. NOT WORKING YET.
    #' @return A new `AsyncQueue` object
    initialize = function(..., .list = list(), bucket_size = 5,
      sleep = 0, req_per_sec = NULL, req_per_hr = NULL) {
      super$initialize(..., .list = .list)
      self$bucket_size <- bucket_size
      self$sleep <- sleep
      self$req_per_sec <- req_per_sec
      self$req_per_hr <- req_per_hr
      private$fill_buckets()
    },

    #' @description Execute asynchronous requests
    #' @return nothing, responses stored inside object, though will print
    #' messages if you choose verbose output
    request = function() {
      for (i in seq_along(private$buckets)) {
        super$output <- c(super$output, super$async_request(private$buckets[[i]]))
        if (i < length(private$buckets)) {
          # cat(sprintf("i=%s; sleeping %s seconds", i, self$sleep), sep ="\n")
          Sys.sleep(self$sleep)
        }
      }
    },

    #' @description List responses
    #' @return a list of `HttpResponse` objects, empty list before
    #' requests made
    responses = function() {
      super$output %||% list()
    }
  ),

  private = list(
    print_string = "<crul async queue>",
    buckets = list(),
    fill_buckets = function() {
      x <- super$requests()
      if (length(x) > 0) {
        private$buckets <- split(x, ceiling(seq_along(x)/self$bucket_size))
      }
    }
  )
)
