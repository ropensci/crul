#' @title Async client for different request types
#' @description
#' An async client to do many requests, each with different URLs, curl options,
#' etc.
#'
#' @export
#' @family async
#' @template async-deets
#' @template r6
#' @return An object of class `AsyncVaried` with variables and methods.
#' [HttpResponse] objects are returned in the order they are passed in.
#' We print the first 10.
#' @examplesIf interactive()
#' # pass in requests via ...
#' req1 <- HttpRequest$new(
#'   url = "https://hb.opencpu.org/get",
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )$get()
#' req2 <- HttpRequest$new(url = "https://hb.opencpu.org/post")$post()
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
#'   url = "https://hb.opencpu.org/post",
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )$verb(method)
#' req2 <- HttpRequest$new(url = "https://hb.opencpu.org/post")$verb(method)
#' out <- AsyncVaried$new(req1, req2)
#' out
#' out$request()
#' out$responses()
#'
#' # pass in requests in a list via .list param
#' reqlist <- list(
#'   HttpRequest$new(url = "https://hb.opencpu.org/get")$get(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/post")$post(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/put")$put(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/delete")$delete(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/get?g=5")$get(),
#'   HttpRequest$new(
#'     url = "https://hb.opencpu.org/post")$post(body = list(y = 9)),
#'   HttpRequest$new(
#'     url = "https://hb.opencpu.org/get")$get(query = list(hello = "world"))
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
#' url <- "https://hb.opencpu.org/basic-auth/user/passwd"
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
#'   HttpRequest$new(url = "https://hb.opencpu.org")$head(),
#'   HttpRequest$new(url = "https://hb.opencpu.org",
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
#'
#' # retry
#' reqlist <- list(
#'   HttpRequest$new(url = "https://hb.opencpu.org/get")$get(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/post")$post(),
#'   HttpRequest$new(url = "https://hb.opencpu.org/status/404")$retry("get"),
#'   HttpRequest$new(url = "https://hb.opencpu.org/status/429")$retry("get",
#'    retry_only_on = c(403, 429), times = 2)
#' )
#' tmp <- AsyncVaried$new(.list = reqlist)
#' tmp
#' tmp$request()
#' tmp$responses()[[3]]
#'
#' # mock
#' url <- "https://hb.opencpu.org/get"
#' mock_fun <- function(status) {
#'   function(req) {
#'     HttpResponse$new(method = "GET", url = "http://google.com",
#'       status_code = status)
#'   }
#' }
#' reqlist <- list(
#'   HttpRequest$new(url = url)$get(mock = mock_fun(status=418L)),
#'   HttpRequest$new(url = url)$get(mock = mock_fun(status=201)),
#'   HttpRequest$new(url = url)$get(mock = mock_fun(status=501L))
#' )
#' tmp <- AsyncVaried$new(.list = reqlist)
#' tmp
#' tmp$request()
#' tmp$status()
AsyncVaried <- R6::R6Class(
  "AsyncVaried",
  public = list(
    #' @field mock a mocking function. could be `NULL` too
    mock = NULL,

    #' @description print method for AsyncVaried objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat(private$print_string, sep = "\n")
      cat(sprintf("  requests: (n: %s)", length(private$reqs)), sep = "\n")
      print_urls <- private$reqs[1:min(c(length(private$reqs), 10))]
      for (i in seq_along(print_urls)) {
        retry_note <- if ("retry_options" %in% names(print_urls[[i]]$payload)) {
          " (retry)"
        } else {
          ""
        }
        cat(
          sprintf(
            "   %s: %s",
            paste0(print_urls[[i]]$payload$method, retry_note),
            print_urls[[i]]$url
          ),
          "\n"
        )
      }
      if (length(private$reqs) > 10) {
        cat(
          sprintf("   # ... with %s more", length(private$reqs) - 10),
          sep = "\n"
        )
      }
      invisible(self)
    },

    #' @description Create a new AsyncVaried object
    #' @param ...,.list Any number of objects of class [HttpRequest()],
    #' must supply inputs to one of these parameters, but not both
    #' @param mock A mocking function. If supplied, this function is called
    #' with the request. It should return either `NULL` (if it doesn't want to
    #' handle the request) or a [HttpResponse] (if it does).
    #' @return A new `AsyncVaried` object
    initialize = function(
      ...,
      .list = list(),
      mock = getOption("crul_mock", NULL)
    ) {
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
      if (!is.null(mock)) {
        self$mock <- mock
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
    #' @details An S3 print method is used to summarise results. [unclass]
    #' the output to see the list, or index to results, e.g., `[1]`, `[1:3]`
    responses = function() {
      structure(private$output %||% list(), class = "asyncresponses")
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
      retry <- function(
        i,
        handle,
        pause_base,
        pause_cap,
        pause_min,
        times,
        terminate_on,
        retry_only_on,
        onwait
      ) {
        curl::multi_add(handle, pool = crulpool, done = function(res) {
          if (
            (res$status_code >= 400) &&
              (!res$status_code %in% terminate_on) &&
              (is.null(retry_only_on) || res$status_code %in% retry_only_on) &&
              (times > 0) &&
              (pause_base < pause_cap)
          ) {
            rh <- res$response_headers
            if (!is.null(rh[["retry-after"]])) {
              wait_time <- as.numeric(rh[["retry-after"]])
            } else if (
              identical(rh[["x-ratelimit-remaining"]], "0") &&
                !is.null(rh[["x-ratelimit-reset"]])
            ) {
              wait_time <- max(
                0,
                as.numeric(rh[["x-ratelimit-reset"]]) -
                  as.numeric(Sys.time())
              )
            } else {
              if (is.null(pause_min)) {
                pause_min <- pause_base
              }
              # exponential backoff with full jitter
              wait_time <- stats::runif(
                1,
                min = pause_min,
                max = min(pause_base * 2, pause_cap)
              )
            }
            if (!(wait_time > pause_cap)) {
              if (is.function(onwait)) {
                onwait(res, wait_time)
              }
              Sys.sleep(wait_time)
              retry(
                i,
                handle,
                pause_base = pause_base * 2,
                pause_cap = pause_cap,
                pause_min = pause_min,
                times = times - 1,
                terminate_on = terminate_on,
                retry_only_on = retry_only_on,
                onwait = onwait
              )
            }
          } else {
            multi_res[[i]] <<- res
          }
        })
      }

      crulpool <- curl::new_pool()
      multi_res <- list()

      make_request <- function(i) {
        request <- reqs[[i]]$payload
        handle <- request$url$handle
        curl::handle_setopt(handle, .list = request$options)
        if (!is.null(request$fields)) {
          curl::handle_setform(handle, .list = request$fields)
        }
        curl::handle_setheaders(handle, .list = request$headers)

        if ("retry_options" %in% names(request)) {
          do.call(retry, c(list(i = i, handle = handle), request$retry_options))
        } else if (is.null(request$disk) && is.null(request$stream)) {
          mock_fun <- as_mock_fun(request$mock, error_call)
          if (!is.null(mock_fun)) {
            multi_res[[i]] <<- mock_fun(request)
          } else {
            curl::multi_add(
              handle = handle,
              done = function(res) multi_res[[i]] <<- res,
              fail = function(res) {
                multi_res[[i]] <<- make_async_error(res, request)
              },
              pool = crulpool
            )
          }
        } else {
          if (!is.null(request$disk) && is.null(request$stream)) {
            stopifnot(inherits(request$disk, "character"))
            file_con <- file(request$disk, open = "wb")
            curl::multi_add(
              handle = handle,
              done = function(res) {
                close(file_con)
                multi_res[[i]] <<- res
              },
              fail = function(res) {
                close(file_con)
                multi_res[[i]] <<- make_async_error(res, request)
              },
              data = file_con,
              pool = crulpool
            )
          } else if (is.null(request$disk) && !is.null(request$stream)) {
            stopifnot(is.function(request$stream))
            # assign empty response since stream is a user supplied function
            # to write somewhere of their choosing
            multi_res[[i]] <<- make_async_error("", request)
            curl::multi_add(
              handle = handle,
              done = request$stream,
              fail = function(res) {
                multi_res[[i]] <<- make_async_error(res, request)
              },
              pool = crulpool
            )
          }
        }
      }

      for (i in seq_along(reqs)) {
        make_request(i)
      }

      if (!is.null(as_mock_fun(self$mock, error_call))) {
        return(multi_res)
      }

      curl::multi_run(pool = crulpool)
      remain <- curl::multi_list(crulpool)
      if (length(remain)) {
        lapply(remain, curl::multi_cancel)
      }
      multi_res <- ccp(multi_res)

      Map(
        function(z, b) {
          # prep headers
          if (grepl("^ftp://", z$url)) {
            headers <- list()
          } else {
            headers_temp <- rawToChar(z$headers %||% raw(0))
            if (nzchar(headers_temp)) {
              headers <- lapply(
                curl::parse_headers(headers_temp, multiple = TRUE),
                head_parse
              )
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
        },
        multi_res,
        reqs
      )
    }
  )
)

make_async_error <- function(x, req) {
  list(
    url = req$url$url,
    status_code = 0,
    headers = raw(0),
    modified = NA_character_,
    times = NA_character_,
    content = charToRaw(x)
  )
}

#' @export
print.asyncresponses <- function(x, ...) {
  cat("async responses", sep = "\n")
  cat(
    sprintf("status code - url (N=%s; printing up to 10)", length(x)),
    sep = "\n"
  )
  if (length(x) == 0) {
    cat("  empty", sep = "\n")
  }
  for (i in seq_len(min(c(10, length(x))))) {
    cat(sprintf("  %s - %s", x[[i]]$status_code, x[[i]]$url), sep = "\n")
  }
}
