#' @title AsyncQueue
#' @description An AsyncQueue client
#' @export
#' @family async
#' @template r6
#' @examples \dontrun{
#' # Using sleep (note this works with retry requests)
#' reqlist <- list(
#'   HttpRequest$new(url = "https://hb.opencpu.org/get")$get(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/post")$post(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/put")$put(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/delete")$delete(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/get?g=5")$get(),
#'   HttpRequest$new(
#'     url = "https://hb.opencpu.org/post")$post(body = list(y = 9)),
#'   HttpRequest$new(
#'     url = "https://hb.opencpu.org/get")$get(query = list(hello = "world")),
#'   HttpRequest$new(url = "https://ropensci.org")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/about")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/packages")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/community")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/blog")$get(),
#'   HttpRequest$new(url = "https://ropensci.org/careers")$get(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/status/404")$retry("get")
#' )
#' out <- AsyncQueue$new(.list = reqlist, bucket_size = 5, sleep = 3)
#' out
#' out$bucket_size # bucket size
#' out$requests() # list requests
#' out$request() # make requests
#' out$responses() # list responses
#'
#' # Using requests per minute
#' if (interactive()) {
#' x="https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/registry.json"
#' z <- HttpClient$new(x)$get()
#' urls <- jsonlite::fromJSON(z$parse("UTF-8"))$packages$url
#' repos = Filter(length, regmatches(urls, gregexpr("ropensci/[A-Za-z]+", urls)))
#' repos = unlist(repos)
#' auth <- list(Authorization = paste("token", Sys.getenv('GITHUB_PAT')))
#' reqs <- lapply(repos[1:50], function(w) {
#'   HttpRequest$new(paste0("https://api.github.com/repos/", w), headers = auth)$get()
#' })
#'
#' out <- AsyncQueue$new(.list = reqs, req_per_min = 30)
#' out
#' out$bucket_size
#' out$requests()
#' out$request()
#' out$responses()
#' }}
AsyncQueue <- R6::R6Class(
  'AsyncQueue',
  inherit = AsyncVaried,
  public = list(
    #' @field bucket_size (integer) number of requests to send at once
    bucket_size = 5,
    #' @field sleep (integer) number of seconds to sleep between each bucket
    sleep = NULL,
    #' @field req_per_min (integer) requests per minute
    req_per_min = NULL,

    #' @description print method for AsyncQueue objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      super$print()
      cat(paste0("  bucket_size: ", self$bucket_size), sep = "\n")
      cat(paste0("  sleep: ", self$sleep), sep = "\n")
      cat(paste0("  req_per_min: ", self$req_per_min), sep = "\n")
      invisible(self)
    },

    #' @description Create a new `AsyncQueue` object
    #' @param ...,.list Any number of objects of class [HttpRequest()],
    #' must supply inputs to one of these parameters, but not both
    #' @param bucket_size (integer) number of requests to send at once.
    #' default: 5. See Details.
    #' @param sleep (integer) seconds to sleep between buckets.
    #' default: NULL (not set)
    #' @param req_per_min (integer) maximum number of requests per minute.
    #' if `NULL` (default), its ignored
    #' @details Must set either `sleep` or `req_per_min`. If you set
    #' `req_per_min` we calculate a new `bucket_size` when `$new()` is
    #' called
    #' @return A new `AsyncQueue` object
    initialize = function(
      ...,
      .list = list(),
      bucket_size = 5,
      sleep = NULL,
      req_per_min = NULL
    ) {
      super$initialize(..., .list = .list)
      self$bucket_size <- bucket_size
      self$sleep <- sleep
      self$req_per_min <- req_per_min
      if (!xor(!is.null(self$sleep), !is.null(self$req_per_min))) {
        stop("must set either sleep or req_per_min to non-NULL integer")
      }
      if (!is.null(self$req_per_min)) {
        self$bucket_size <- self$req_per_min
      }
      private$fill_buckets()
    },

    #' @description Execute asynchronous requests
    #' @return nothing, responses stored inside object, though will print
    #' messages if you choose verbose output
    request = function() {
      if (!is.null(self$sleep)) {
        private$request_sleep()
      }
      if (!is.null(self$req_per_min)) private$request_rate()
    },

    #' @description List responses
    #' @return a list of `HttpResponse` objects, empty list before
    #' requests made
    responses = function() {
      super$output %||% list()
    },

    #' @description parse content
    #' @param encoding (character) the encoding to use in parsing.
    #' default:"UTF-8"
    #' @return character vector, empty character vector before
    #' requests made
    parse = function(encoding = "UTF-8") {
      vapply(super$output, function(z) z$parse(encoding = encoding), "")
    },

    #' @description Get HTTP status codes for each response
    #' @return numeric vector, empty numeric vector before requests made
    status_code = function() {
      vapply(super$output, function(z) z$status_code, 1)
    },

    #' @description List HTTP status objects
    #' @return a list of `http_code` objects, empty list before requests made
    status = function() {
      lapply(super$output, function(z) z$status_http())
    },

    #' @description Get raw content for each response
    #' @return raw list, empty list before requests made
    content = function() {
      lapply(super$output, function(z) z$content)
    },

    #' @description curl request times
    #' @return list of named numeric vectors, empty list before requests made
    times = function() {
      lapply(super$output, function(z) z$times)
    }
  ),

  private = list(
    print_string = "<crul async queue>",
    buckets = list(),
    fill_buckets = function() {
      x <- super$requests()
      if (length(x) > 0) {
        private$buckets <- split(x, ceiling(seq_along(x) / self$bucket_size))
      }
    },
    request_sleep = function() {
      for (i in seq_along(private$buckets)) {
        super$output <- c(
          super$output,
          super$async_request(private$buckets[[i]])
        )
        if (i < length(private$buckets)) Sys.sleep(self$sleep)
      }
    },
    request_rate = function() {
      for (i in seq_along(private$buckets)) {
        start <- Sys.time()
        super$output <- c(
          super$output,
          super$async_request(private$buckets[[i]])
        )
        if (i < length(private$buckets)) {
          now <- Sys.time()
          diff_time <- now - start
          if (diff_time < 60L) Sys.sleep(60L - diff_time)
        }
      }
    }
  )
)
