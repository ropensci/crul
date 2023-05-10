#' @title Simple async client
#' @description
#' An async client to work with many URLs, but all with the same HTTP method
#'
#' @export
#' @family async
#' @template async-deets
#' @template r6
#' @param path (character) URL path, appended to the base URL
#' @param query (list) query terms, as a named list
#' @param disk a path to write to. if NULL (default), memory used.
#' See [curl::curl_fetch_disk()] for help.
#' @param stream an R function to determine how to stream data. if
#' `NULL` (default), memory used. See [curl::curl_fetch_stream()]
#' for help
#' @param ... curl options, only those in the acceptable set from
#' [curl::curl_options()] except the following: httpget, httppost, post,
#' postfields, postfieldsize, and customrequest
#' @details
#' See [HttpClient()] for information on parameters.
#' @return a list, with objects of class [HttpResponse()].
#' Responses are returned in the order they are passed in. We print the 
#' first 10.
#' @examples \dontrun{
#' cc <- Async$new(
#'   urls = c(
#'     'https://hb.opencpu.org/',
#'     'https://hb.opencpu.org/get?a=5',
#'     'https://hb.opencpu.org/get?foo=bar'
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
#' lapply(res, function(z) z$parse("UTF-8"))
#' 
#' # curl options/headers with async
#' urls = c(
#'  'https://hb.opencpu.org/',
#'  'https://hb.opencpu.org/get?a=5',
#'  'https://hb.opencpu.org/get?foo=bar'
#' )
#' cc <- Async$new(urls = urls, 
#'   opts = list(verbose = TRUE),
#'   headers = list(foo = "bar")
#' )
#' cc
#' (res <- cc$get())
#' 
#' # using auth with async
#' dd <- Async$new(
#'   urls = rep('https://hb.opencpu.org/basic-auth/user/passwd', 3),
#'   auth = auth(user = "foo", pwd = "passwd"),
#'   opts = list(verbose = TRUE)
#' )
#' dd
#' res <- dd$get()
#' res
#' vapply(res, function(z) z$status_code, double(1))
#' vapply(res, function(z) z$success(), logical(1))
#' lapply(res, function(z) z$parse("UTF-8"))
#' 
#' # failure behavior
#' ## e.g. when a URL doesn't exist, a timeout, etc.
#' urls <- c("http://stuffthings.gvb", "https://foo.com", 
#'   "https://hb.opencpu.org/get")
#' conn <- Async$new(urls = urls)
#' res <- conn$get()
#' res[[1]]$parse("UTF-8") # a failure
#' res[[2]]$parse("UTF-8") # a failure
#' res[[3]]$parse("UTF-8") # a success
#' 
#' # retry
#' urls = c("https://hb.opencpu.org/status/404", "https://hb.opencpu.org/status/429")
#' conn <- Async$new(urls = urls)
#' res <- conn$retry(verb="get")
#' }
Async <- R6::R6Class(
  'Async',
  public = list(
    #' @field urls (character) one or more URLs
    urls = NULL,
    #' @field opts any curl options
    opts = NULL,
    #' @field proxies named list of headers
    proxies = NULL,
    #' @field auth an object of class `auth`
    auth = NULL,
    #' @field headers named list of headers
    headers = NULL,

    #' @description print method for Async objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat("<crul async connection> ", sep = "\n")

      cat("  curl options: ", sep = "\n")
      for (i in seq_along(self$opts)) {
        cat(sprintf("    %s: %s", names(self$opts)[i],
                    self$opts[[i]]), sep = "\n")
      }
      cat("  proxies: ", sep = "\n")
      if (length(self$proxies)) cat(paste("    -",
                                          purl(self$proxies)), sep = "\n")
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

      cat(sprintf("  urls: (n: %s)", length(self$urls)), sep = "\n")
      print_urls <- self$urls[1:min(c(length(self$urls), 10))]
      for (i in seq_along(print_urls)) {
        cat(paste0("   ", print_urls[[i]]), sep = "\n")
      }
      if (length(self$urls) > 10) {
        cat(sprintf("   # ... with %s more", length(self$urls) - 10), sep = "\n")
      }
      invisible(self)
    },

    #' @description Create a new Async object
    #' @param urls (character) one or more URLs
    #' @param opts any curl options
    #' @param proxies a [proxy()] object
    #' @param auth an [auth()] object
    #' @param headers named list of headers
    #' @return A new `Async` object.
    initialize = function(urls, opts, proxies, auth, headers) {
      self$urls <- urls
      if (!missing(opts)) self$opts <- opts
      if (!missing(proxies)) self$proxies <- proxies
      if (!missing(auth)) self$auth <- auth
      if (!missing(headers)) self$headers <- headers
    },

    #' @description
    #' execute the `GET` http verb for the `urls`
    #' @examples \dontrun{
    #' (cc <- Async$new(urls = c(
    #'     'https://hb.opencpu.org/',
    #'     'https://hb.opencpu.org/get?a=5',
    #'     'https://hb.opencpu.org/get?foo=bar'
    #'   )))
    #' (res <- cc$get())
    #' }
    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      private$gen_interface(self$urls, "get", path, query,
        disk = disk, stream = stream, ...)
    },

    #' @description
    #' execute the `POST` http verb for the `urls`
    #' @param body body as an R list
    #' @param encode one of form, multipart, json, or raw
    post = function(path = NULL, query = list(), body = NULL,
                    encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "post", path, query, body, encode,
        disk, stream, ...)
    },

    #' @description
    #' execute the `PUT` http verb for the `urls`
    #' @param body body as an R list
    #' @param encode one of form, multipart, json, or raw
    put = function(path = NULL, query = list(), body = NULL,
                   encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "put", path, query, body, encode,
        disk, stream, ...)
    },

    #' @description
    #' execute the `PATCH` http verb for the `urls`
    #' @param body body as an R list
    #' @param encode one of form, multipart, json, or raw
    patch = function(path = NULL, query = list(), body = NULL,
                     encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "patch", path, query, body, encode,
        disk, stream, ...)
    },

    #' @description
    #' execute the `DELETE` http verb for the `urls`
    #' @param body body as an R list
    #' @param encode one of form, multipart, json, or raw
    delete = function(path = NULL, query = list(), body = NULL,
                      encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "delete", path, query, body, encode,
        disk, stream, ...)
    },

    #' @description
    #' execute the `HEAD` http verb for the `urls`
    head = function(path = NULL, ...) {
      private$gen_interface(self$urls, "head", path, ...)
    },

    #' @description
    #' execute the `RETRY` http verb for the `urls`. see [`HttpRequest$retry`][HttpRequest] method for parameters
    retry = function(...) {
      private$gen_interface(self$urls, "retry", ...)
    },

    #' @description
    #' execute any supported HTTP verb
    #' @param verb (character) a supported HTTP verb: get, post, put, patch, delete,
    #' head.
    #' @examples \dontrun{
    #' cc <- Async$new(
    #'   urls = c(
    #'     'https://hb.opencpu.org/',
    #'     'https://hb.opencpu.org/get?a=5',
    #'     'https://hb.opencpu.org/get?foo=bar'
    #'   )
    #' )
    #' (res <- cc$verb('get'))
    #' lapply(res, function(z) z$parse("UTF-8"))
    #' }
    verb = function(verb, ...) {
      stopifnot(is.character(verb), length(verb) > 0)
      verbs <- c('get', 'post', 'put', 'patch', 'delete', 'head')
      if (!tolower(verb) %in% verbs) stop("'verb' must be one of: ", paste0(verbs, collapse = ", "))
      verbFunc <- self[[tolower(verb)]]
      stopifnot(is.function(verbFunc))
      verbFunc(...)
    }
  ),

  private = list(
    gen_interface = function(x, method, path, query = NULL, body = NULL,
      encode = NULL, disk = NULL, stream = NULL, ...) {
      if (!is.null(disk)) {
        stopifnot("urls must be same length as disk" = length(x) == length(disk))
        reqs <- Map(function(z, m) {
          switch(
            method,
            get = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$get(
              path = path, query = query, disk = m, stream = stream, ...
            ),
            post = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$post(
              path = path, query = query, body = body, encode = encode, 
              disk = m, stream = stream,
              ...
            ),
            put = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$put(
              path = path, query = query, body = body, encode = encode, 
              disk = m, stream = stream,
              ...
            ),
            patch = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$patch(
              path = path, query = query,
              body = body, encode = encode, disk = m, stream = stream,
              ...
            ),
            delete = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, headers = self$headers
            )$delete(
              path = path, query = query, body = body, encode = encode, 
              disk = m, stream = stream, ...
            ),
            head = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth,
              headers = self$headers
            )$head(path = path, ...),
            retry = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$retry(...)
          )
        }, x, disk)
      } else {
        reqs <- lapply(x, function(z) {
          switch(
            method,
            get = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers)$get(
              path = path, query = query, disk = disk, stream = stream, ...
            ),
            post = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$post(path = path, query = query, body = body, encode = encode, 
              disk = disk, stream = stream, ...
            ),
            put = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$put(
              path = path, query = query, body = body, encode = encode, 
              disk = disk, stream = stream, ...
            ),
            patch = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$patch(
              path = path, query = query, body = body, encode = encode, 
              disk = disk, stream = stream, ...
            ),
            delete = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$delete(
              path = path, query = query, body = body, encode = encode, 
              disk = disk, stream = stream, ...
            ),
            head = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$head(path = path, ...),
            retry = HttpRequest$new(url = z, opts = self$opts, 
              proxies = self$proxies, auth = self$auth, 
              headers = self$headers
            )$retry(...)
          )
        })
      }
      tmp <- AsyncVaried$new(.list = reqs)
      tmp$request()
      tmp$responses()
    }
  )
)
