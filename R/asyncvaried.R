#' @title Async client for different request types
#' @description
#' An async client to do many requests, each with different URLs, curl options,
#' etc.
#'
#' @export
#' @family async
#' @template async-deets
#' @return An object of class `AsyncVaried` with variables and methods.
#' [HttpResponse] objects are returned in the order they are passed in. 
#' We print the first 10.
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
#' # use $verb() method to select http verb
#' method <- "post"
#' req1 <- HttpRequest$new(
#'   url = "https://httpbin.org/post",
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )$verb(method)
#' req2 <- HttpRequest$new(url = "https://httpbin.org/post")$verb(method)
#' out <- AsyncVaried$new(req1, req2)
#' out
#' out$request()
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
#' 
#' # using auth with async
#' url <- "https://httpbin.org/basic-auth/user/passwd"
#' auth <- auth(user = "user", pwd = "passwd")
#' reqlist <- list(
#'   HttpRequest$new(url = url, auth = auth)$get(),
#'   HttpRequest$new(url = url, auth = auth)$get(query = list(a=5)),
#'   HttpRequest$new(url = url, auth = auth)$get(query = list(b=3))
#' )
#' out <- AsyncVaried$new(.list = reqlist)
#' out$request()
#' out$status()
#' out$parse()
#' 
#' # failure behavior
#' ## e.g. when a URL doesn't exist, a timeout, etc.
#' reqlist <- list(
#'   HttpRequest$new(url = "http://stuffthings.gvb")$get(),
#'   HttpRequest$new(url = "https://httpbin.org")$head(),
#'   HttpRequest$new(url = "https://httpbin.org", 
#'    opts = list(timeout_ms = 10))$head()
#' )
#' (tmp <- AsyncVaried$new(.list = reqlist))
#' tmp$request()
#' tmp$responses()
#' tmp$parse("UTF-8")
#' 
#' # access intemediate redirect headers
#' dois <- c("10.7202/1045307ar", "10.1242/jeb.088898", "10.1121/1.3383963")
#' reqlist <- list(
#'   HttpRequest$new(url = paste0("https://doi.org/", dois[1]))$get(),
#'   HttpRequest$new(url = paste0("https://doi.org/", dois[2]))$get(),
#'   HttpRequest$new(url = paste0("https://doi.org/", dois[3]))$get()
#' )
#' tmp <- AsyncVaried$new(.list = reqlist)
#' tmp$request()
#' tmp
#' lapply(tmp$responses(), "[[", "response_headers_all")
#' }
AsyncVaried <- R6::R6Class(
  "AsyncVaried",
  public = list(    
    #' @description print method for AsyncVaried objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat(private$print_string, sep = "\n")
      cat(sprintf("  requests: (n: %s)", length(private$reqs)), sep = "\n")
      print_urls <- private$reqs[1:min(c(length(private$reqs), 10))]
      for (i in seq_along(print_urls)) {
        cat(sprintf("   %s: %s",
                    print_urls[[i]]$payload$method,
                    print_urls[[i]]$url), "\n")
      }
      if (length(private$reqs) > 10) {
        cat(sprintf("   # ... with %s more", length(private$reqs) - 10),
          sep = "\n")
      }
      invisible(self)
    },

    #' @description Create a new AsyncVaried object
    #' @param ...,.list Any number of objects of class [HttpRequest()],
    #' must supply inputs to one of these parameters, but not both
    #' @return A new `AsyncVaried` object
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

    #' @description Execute asynchronous requests
    #' @return nothing, responses stored inside object, though will print
    #' messages if you choose verbose output
    request = function() {
      private$output <- private$async_request(private$reqs)
    },

    #' @description List responses
    #' @return a list of `HttpResponse` objects, empty list before
    #' requests made
    responses = function() {
      private$output %||% list()
    },

    #' @description List requests
    #' @return a list of `HttpRequest` objects, empty list before
    #' requests made
    requests = function() {
      private$reqs
    },

    #' @description parse content
    #' @param encoding (character) the encoding to use in parsing.
    #' default:"UTF-8"
    #' @return character vector, empty character vector before
    #' requests made
    parse = function(encoding = "UTF-8") {
      vapply(private$output, function(z) z$parse(encoding = encoding), "")
    },

    #' @description Get HTTP status codes for each response
    #' @return numeric vector, empty numeric vector before requests made
    status_code = function() {
      vapply(private$output, function(z) z$status_code, 1)
    },

    #' @description List HTTP status objects
    #' @return a list of `http_code` objects, empty list before requests made
    status = function() {
      lapply(private$output, function(z) z$status_http())
    },

    #' @description Get raw content for each response
    #' @return raw list, empty list before requests made
    content = function() {
      lapply(private$output, function(z) z$content)
    },

    #' @description curl request times
    #' @return list of named numeric vectors, empty list before requests made
    times = function() {
      lapply(private$output, function(z) z$times)
    }
  ),

  private = list(
    print_string = "<crul async varied connection>",
    reqs = NULL,
    output = NULL,

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
            fail = function(res) multi_res[[i]] <<- make_async_error(res, w),
            pool = crulpool
          )
        } else {
          if (!is.null(w$disk) && is.null(w$stream)) {
            stopifnot(inherits(w$disk, "character"))
            ff <- file(w$disk, open = "wb")
            curl::multi_add(
              handle = h,
              done = function(res) {
                close(ff)
                multi_res[[i]] <<- res
              },
              fail = function(res) {
                close(ff)
                multi_res[[i]] <<- make_async_error(res, w)
              },
              data = ff,
              pool = crulpool
            )
          } else if (is.null(w$disk) && !is.null(w$stream)) {
            stopifnot(is.function(w$stream))
            # assign empty response since stream is a user supplied function
            # to write somewhere of their choosing
            multi_res[[i]] <<- make_async_error("", w)
            curl::multi_add(
              handle = h,
              done = w$stream,
              fail = function(res) multi_res[[i]] <<- make_async_error(res, w),
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
        # prep headers
        if (grepl("^ftp://", z$url)) {
          headers <- list()
        } else {
          hh <- rawToChar(z$headers %||% raw(0))
          if (nzchar(hh)) {
            headers <- lapply(curl::parse_headers(hh, multiple = TRUE),
              head_parse)
          } else {
            headers <- list()
          }
        }
        HttpResponse$new(
          method = b$payload$method,
          url = z$url,
          status_code = z$status_code,
          request_headers = c(
            useragent = b$payload$options$useragent,
            b$headers
          ),
          response_headers = last(headers),
          response_headers_all = headers,
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

make_async_error <- function(x, req) {
  list(url = req$url$url, status_code = 0, headers = raw(0), 
    modified = NA_character_, times = NA_character_, 
    content = charToRaw(x))
}
