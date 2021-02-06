#' @title HTTP client
#' @description Create and execute HTTP requests
#'
#' @export
#' @template args
#' @param path URL path, appended to the base URL
#' @param query query terms, as a named list. any numeric values are
#' passed through [format()] to prevent larger numbers from being
#' scientifically formatted
#' @param body body as an R list
#' @param encode one of form, multipart, json, or raw
#' @param disk a path to write to. if NULL (default), memory used.
#' See [curl::curl_fetch_disk()] for help.
#' @param stream an R function to determine how to stream data. if
#' NULL (default), memory used. See [curl::curl_fetch_stream()]
#' for help
#' @param ... For `retry`, the options to be passed on to the method
#' implementing the requested verb, including curl options. Otherwise,
#' curl options, only those in the acceptable set from [curl::curl_options()]
#' except the following: httpget, httppost, post, postfields, postfieldsize,
#' and customrequest
#' @return an [HttpResponse] object
#' @section handles:
#' curl handles are re-used on the level of the connection object, that is,
#' each `HttpClient` object is separate from one another so as to better
#' separate connections.
#'
#' If you don't pass in a curl handle to the `handle` parameter,
#' it gets created when a HTTP verb is called. Thus, if you try to get `handle`
#' after creating a `HttpClient` object only passing `url` parameter, `handle`
#' will be `NULL`. If you pass a curl handle to the `handle` parameter, then
#' you can get the handle from the `HttpClient` object. The response from a
#' http verb request does have the handle in the `handle` slot.
#'
#' @note A little quirk about `crul` is that because user agent string can
#' be passed as either a header or a curl option (both lead to a `User-Agent`
#' header being passed in the HTTP request), we return the user agent
#' string in the `request_headers` list of the response even if you
#' pass in a `useragent` string as a curl option. Note that whether you pass
#' in as a header like `User-Agent` or as a curl option like `useragent`,
#' it is returned as `request_headers$User-Agent` so at least accessing
#' it in the request headers is consistent.
#'
#' @seealso [http-headers], [writing-options], [cookies], [hooks]
#'
#' @examples \dontrun{
#' # set your own handle
#' (h <- handle("https://httpbin.org"))
#' (x <- HttpClient$new(handle = h))
#' x$handle
#' x$url
#' (out <- x$get("get"))
#' x$handle
#' x$url
#' class(out)
#' out$handle
#' out$request_headers
#' out$response_headers
#' out$response_headers_all
#'
#' # if you just pass a url, we create a handle for you
#' #  this is how most people will use HttpClient
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' x$url
#' x$handle # is empty, it gets created when a HTTP verb is called
#' (r1 <- x$get('get'))
#' x$url
#' x$handle
#' r1$url
#' r1$handle
#' r1$content
#' r1$response_headers
#' r1$parse()
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
#'
#' # query params are URL encoded for you, so DO NOT do it yourself
#' ## if you url encode yourself, it gets double encoded, and that's bad
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' res <- x$get("get", query = list(a = 'hello world'))
#'
#' # access intermediate headers in response_headers_all
#' x <- HttpClient$new("https://doi.org/10.1007/978-3-642-40455-9_52-1")
#' bb <- x$get()
#' bb$response_headers_all
#' }

HttpClient <- R6::R6Class(
  'HttpClient',
  public = list(
    #' @field url (character) a url
    url = NULL,
    #' @field opts (list) named list of curl options
    opts = list(),
    #' @field proxies a [proxy()] object
    proxies = list(),
    #' @field auth an [auth()] object
    auth = list(),
    #' @field headers (list) named list of headers, see [http-headers]
    headers = list(),
    #' @field handle a [handle()]
    handle = NULL,
    #' @field progress only supports `httr::progress()`, see [progress]
    progress = NULL,
    #' @field hooks a named list, see [hooks]
    hooks = list(),

    #' @description print method for `HttpClient` objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat("<crul connection> ", sep = "\n")
      cat(paste0("  url: ",
                 if (is.null(self$url)) self$handle$url else self$url),
          sep = "\n")
      cat("  curl options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        z <- if (inherits(self$opts[[i]], "function")) "<function>" else self$opts[[i]]
        cat(sprintf("    %s: %s", names(self$opts)[i], z), sep = "\n")
      }
      cat("  proxies: ", sep = "\n")
      if (length(self$proxies)) cat(paste("    -", purl(self$proxies)),
                                    sep = "\n")
      cat("  auth: ", sep = "\n")
      if (length(self$auth$userpwd)) {
        cat(paste("    -", self$auth$userpwd), sep = "\n")
        cat(paste("    - type: ", self$auth$httpauth), sep = "\n")
      }
      cat("  headers: ", sep = "\n")
      for (i in seq_along(self$headers)) {
        cat(sprintf("    %s: %s", names(self$headers)[i],
                    self$headers[[i]]), sep = "\n")
      }
      cat(paste0("  progress: ", !is.null(self$progress)), sep = "\n")
      cat("  hooks: ", sep = "\n")
      if (length(self$hooks) > 0) {
        for (i in seq_along(self$hooks)) {
          cat(sprintf("    %s: see $hooks", names(self$hooks)[i]), sep = "\n")
        }
      }
      invisible(self)
    },

    #' @description Create a new HttpClient object
    #' @param urls (character) one or more URLs
    #' @param opts any curl options
    #' @param proxies a [proxy()] object
    #' @param auth an [auth()] object
    #' @param headers named list of headers, see [http-headers]
    #' @param handle a [handle()]
    #' @param progress only supports `httr::progress()`, see [progress]
    #' @param hooks a named list, see [hooks]
    #' @param verbose a special handler for verbose curl output, 
    #' accepts a function only. default is `NULL`. if used, `verbose`
    #' and `debugfunction` curl options are ignored if passed to `opts`
    #' on `$new()` and ignored if `...` passed to a http method call
    #' @return A new `HttpClient` object
    initialize = function(url, opts, proxies, auth, headers, handle,
      progress, hooks, verbose) {
      private$crul_h_pool <- new.env(hash = TRUE, parent = emptyenv())
      if (!missing(url)) self$url <- url

      # curl options: check for set_opts first
      if (!is.null(crul_opts$opts)) self$opts <- crul_opts$opts
      if (!missing(opts) && length(opts) > 0) self$opts <- opts
      if (!missing(verbose)) {
        assert(verbose, "function")
        self$opts$verbose <- TRUE
        self$opts$debugfunction <- verbose
      }

      # proxy: check for set_proxy first
      if (!is.null(crul_opts$proxies)) self$proxies <- crul_opts$proxies
      if (!missing(proxies)) {
        if (!inherits(proxies, "proxy")) {
          stop("proxies input must be of class proxy", call. = FALSE)
        }
        self$proxies <- proxies
      }

      # auth: check for set_auth first
      if (!is.null(crul_opts$auth)) self$auth <- crul_opts$auth
      if (!missing(auth)) self$auth <- auth

      # progress
      if (!missing(progress)) {
        assert(progress, "request")
        self$progress <- progress$options
      }

      # headers: check for set_headers first
      if (!is.null(crul_opts$headers)) self$headers <- crul_opts$headers
      if (!missing(headers)) self$headers <- headers

      if (!missing(handle)) {
        assert(handle, "list")
        stopifnot(all(c("url", "handle") %in% names(handle)))
        self$handle <- handle
      }

      if (is.null(self$url) && is.null(self$handle)) {
        stop("need one of url or handle", call. = FALSE)
      }

      # hooks
      if (!missing(hooks)) {
        assert(hooks, "list")
        if (!all(has_name(hooks))) stop("'hooks' must be a named list",
          call. = FALSE)
        if (!all(names(hooks) %in% c("request", "response")))
          stop("unsupported names in 'hooks' list: only request, ",
            "response supported", call. = FALSE)
        invisible(lapply(hooks, function(z) {
          if (!inherits(z, "function"))
            stop("hooks must be functions", call. = FALSE)
        }))
        self$hooks <- hooks
      }
    },

    #' @description Make a GET request
    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      rr <- list(
        url = url,
        method = "get",
        options = ccp(list(httpget = TRUE)),
        headers = def_head()
      )
      rr$headers <- norm_headers(rr$headers, self$headers)
      if (
        !"useragent" %in% self$opts &&
        !"user-agent" %in% tolower(names(rr$headers))
      ) {
        rr$options$useragent <- make_ua()
      }
      rr$options <- utils::modifyList(
        rr$options, c(self$opts, self$proxies, self$auth, self$progress, ...))
      rr$options <- curl_opts_fil(rr$options)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    #' @description Make a POST request
    post = function(path = NULL, query = list(), body = NULL, disk = NULL,
                    stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("post", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    #' @description Make a PUT request
    put = function(path = NULL, query = list(), body = NULL, disk = NULL,
                   stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("put", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    #' @description Make a PATCH request
    patch = function(path = NULL, query = list(), body = NULL, disk = NULL,
                     stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("patch", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    #' @description Make a DELETE request
    delete = function(path = NULL, query = list(), body = NULL, disk = NULL,
                      stream = NULL, encode = "multipart", ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- prep_body(body, encode)
      rr <- prep_opts("delete", url, self, opts, ...)
      rr$disk <- disk
      rr$stream <- stream
      private$make_request(rr)
    },

    #' @description Make a HEAD request
    head = function(path = NULL, query = list(), ...) {
      curl_opts_check(...)
      url <- private$make_url(self$url, self$handle, path, query)
      opts <- list(customrequest = "HEAD", nobody = TRUE)
      rr <- list(
        url = url,
        method = "head",
        options = ccp(opts),
        headers = self$headers
      )
      if (
        !"useragent" %in% self$opts &&
        !"user-agent" %in% tolower(names(rr$headers))
      ) {
        rr$options$useragent <- make_ua()
      }
      rr$options <- utils::modifyList(
        rr$options,
        c(self$opts, self$proxies, self$auth, ...))
      rr$options <- curl_opts_fil(rr$options)
      private$make_request(rr)
    },

    #' @description Use an arbitrary HTTP verb supported on this class
    #' Supported verbs: "get", "post", "put", "patch", "delete", "head". Also
    #' supports retry
    #' @param verb an HTTP verb supported on this class: "get",
    #' "post", "put", "patch", "delete", "head". Also supports retry.
    #' @examples \dontrun{
    #' (x <- HttpClient$new(url = "https://httpbin.org"))
    #' x$verb('get')
    #' x$verb('GET')
    #' x$verb('GET', query = list(foo = "bar"))
    #' x$verb('retry', 'GET', path = "status/400")
    #' }
    verb = function(verb, ...) {
      stopifnot(is.character(verb), length(verb) > 0)
      verbs <- c("get", "post", "put", "patch",
        "delete", "head", "retry")
      if (!tolower(verb) %in% verbs)
        stop("'verb' must be one of: ", paste0(verbs, collapse = ", "))
      verb_func <- self[[tolower(verb)]]
      stopifnot(is.function(verb_func))
      verb_func(...)
    },

    #' @description Retry a request
    #' @details Retries the request given by `verb` until successful
    #' (HTTP response status < 400), or a condition for giving up is met.
    #' Automatically recognizes `Retry-After` and `X-RateLimit-Reset` headers
    #' in the response for rate-limited remote APIs.
    #' @param verb an HTTP verb supported on this class: "get",
    #' "post", "put", "patch", "delete", "head". Also supports retry.
    #' @param times the maximum number of times to retry. Set to `Inf` to
    #' not stop retrying due to exhausting the number of attempts.
    #' @param pause_base,pause_cap,pause_min basis, maximum, and minimum for
    #' calculating wait time for retry. Wait time is calculated according to the
    #' exponential backoff with full jitter algorithm. Specifically, wait time is
    #' chosen randomly between `pause_min` and the lesser of `pause_base * 2` and
    #' `pause_cap`, with `pause_base` doubling on each subsequent retry attempt.
    #' Use `pause_cap = Inf` to not terminate retrying due to cap of wait time
    #' reached.
    #' @param terminate_on,retry_only_on a vector of HTTP status codes. For
    #' `terminate_on`, the status codes for which to terminate retrying, and for
    #' `retry_only_on`, the status codes for which to retry the request.
    #' @param onwait a callback function if the request will be retried and
    #' a wait time is being applied. The function will be passed two parameters,
    #' the response object from the failed request, and the wait time in seconds.
    #' Note that the time spent in the function effectively adds to the wait time,
    #' so it should be kept simple.
    #' @examples \dontrun{
    #' x <- HttpClient$new(url = "https://httpbin.org")
    #'
    #' # retry, by default at most 3 times
    #' (res_get <- x$retry("GET", path = "status/400"))
    #'
    #' # retry, but not for 404 NOT FOUND
    #' (res_get <- x$retry("GET", path = "status/404", terminate_on = c(404)))
    #'
    #' # retry, but only for exceeding rate limit (note that e.g. Github uses 403)
    #' (res_get <- x$retry("GET", path = "status/429", retry_only_on = c(403, 429)))
    #' }
    retry = function(verb, ...,
                     pause_base = 1, pause_cap = 60, pause_min = 1, times = 3,
                     terminate_on = NULL, retry_only_on = NULL,
                     onwait = NULL) {
      stopifnot(is.character(verb), length(verb) > 0)
      stopifnot(is.null(onwait) || is.function(onwait))
      verb_func <- self[[tolower(verb)]]
      stopifnot(is.function(verb_func))
      resp <- verb_func(...)
      if ((resp$status_code >= 400) &&
          (! resp$status_code %in% terminate_on) &&
          (is.null(retry_only_on) || resp$status_code %in% retry_only_on) &&
          (times > 0) &&
          (pause_base < pause_cap)) {
        rh <- resp$response_headers
        if (! is.null(rh[["retry-after"]])) {
          wait_time <- as.numeric(rh[["retry-after"]])
        } else if (identical(rh[["x-ratelimit-remaining"]], "0") &&
                   ! is.null(rh[["x-ratelimit-reset"]])) {
          wait_time <- max(0, as.numeric(rh[["x-ratelimit-reset"]]) -
            as.numeric(Sys.time()))
        } else {
          if (is.null(pause_min)) pause_min <- pause_base
          # exponential backoff with full jitter
          wait_time <- stats::runif(1,
                                   min = pause_min,
                                   max = min(pause_base * 2, pause_cap))
        }
        if (! (wait_time > pause_cap)) {
          if (is.function(onwait)) onwait(resp, wait_time)
          Sys.sleep(wait_time)
          resp <- self$retry(verb = verb, ...,
                             pause_base = pause_base * 2,
                             pause_cap = pause_cap,
                             pause_min = pause_min,
                             times = times - 1,
                             terminate_on = terminate_on,
                             retry_only_on = retry_only_on,
                             onwait = onwait)
        }
      }
      resp
    },

    #' @description reset your curl handle
    handle_pop = function() {
      name <- handle_make(self$url)
      if (exists(name, envir = private$crul_h_pool)) {
        rm(list = name, envir = private$crul_h_pool)
      }
    },

    #' @description get the URL that would be sent (i.e., before executing
    #' the request) the only things that change the URL are path and query
    #' parameters; body and any curl options don't change the URL
    #' @return URL (character)
    #' @examples
    #' x <- HttpClient$new(url = "https://httpbin.org")
    #' x$url_fetch()
    #' x$url_fetch('get')
    #' x$url_fetch('post')
    #' x$url_fetch('get', query = list(foo = "bar"))
    url_fetch = function(path = NULL, query = list()) {
      private$make_url(self$url, path = path, query = query)$url
    }
  ),

  private = list(
    request = NULL,
    crul_h_pool = NULL,
    handle_find = function(x) {
      z <- handle_make(x)
      if (exists(z, private$crul_h_pool)) {
        handle <- private$crul_h_pool[[z]]
      } else {
        handle <- handle(z)
        private$crul_h_pool[[z]] <- handle
      }
      return(handle)
    },

    make_url = function(url = NULL, handle = NULL, path, query) {
      if (!is.null(handle)) {
        url <- handle$url
      } else {
        handle <- private$handle_find(url)
        url <- handle$url
      }
      if (!is.null(path)) {
        urltools::path(url) <- path
      }
      url <- gsub("\\s", "%20", url)
      url <- add_query(query, url)
      return(list(url = url, handle = handle$handle))
    },

    make_request = function(opts) {
      if (xor(!is.null(opts$disk), !is.null(opts$stream))) {
        if (!is.null(opts$disk) && !is.null(opts$stream)) {
          stop("disk and stream can not be used together", call. = FALSE)
        }
      }
      curl::handle_setopt(opts$url$handle, .list = opts$options)
      if (!is.null(opts$fields)) {
        curl::handle_setform(opts$url$handle, .list = opts$fields)
      }
      curl::handle_setheaders(opts$url$handle, .list = opts$headers)
      on.exit(curl::handle_reset(opts$url$handle), add = TRUE)

      if ("request" %in% names(self$hooks)) self$hooks$request(opts)

      if (crul_opts$mock) {
        check_for_package("webmockr")
        adap <- webmockr::CrulAdapter$new()
        return(adap$handle_request(opts))
      } else {
        resp <- crul_fetch(opts)
      }

      if ("response" %in% names(self$hooks)) self$hooks$response(resp)

      # prep headers
      if (grepl("^ftp://", resp$url)) {
        headers <- list()
      } else {
        hh <- rawToChar(resp$headers %||% raw(0))
        if (is.null(hh) || nchar(hh) == 0) {
          headers <- list()
        } else {
          headers <- lapply(curl::parse_headers(hh, multiple = TRUE),
            head_parse)
        }
      }
      # build response
      HttpResponse$new(
        method = opts$method,
        url = resp$url,
        status_code = resp$status_code,
        request_headers =
        c("User-Agent" = opts$options$useragent, opts$headers),
        response_headers = last(headers),
        response_headers_all = headers,
        modified = resp$modified,
        times = resp$times,
        content = resp$content,
        handle = opts$url$handle,
        request = opts
      )
    }
  )
)
