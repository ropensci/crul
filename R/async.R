#' Simple async client
#'
#' A client to work with many URLs, but all with the same HTTP method
#'
#' @export
#' @param urls (character) one or more URLs (required)
#' @family async
#' @template async-deets
#' @details
#' **Methods**
#'   \describe{
#'     \item{`get(path, query, disk, stream, ...)`}{
#'       make async GET requests for all URLs
#'     }
#'     \item{`post(path, query, body, encode, disk, stream, ...)`}{
#'       make async POST requests for all URLs
#'     }
#'     \item{`put(path, query, body, encode, disk, stream, ...)`}{
#'       make async PUT requests for all URLs
#'     }
#'     \item{`patch(path, query, body, encode, disk, stream, ...)`}{
#'       make async PATCH requests for all URLs
#'     }
#'     \item{`delete(path, query, body, encode, disk, stream, ...)`}{
#'       make async DELETE requests for all URLs
#'     }
#'     \item{`head(path, ...)`}{
#'       make async HEAD requests for all URLs
#'     }
#'   }
#'
#' See [HttpClient()] for information on parameters.
#'
#' @format NULL
#' @usage NULL
#' @return a list, with objects of class [HttpResponse()].
#' Responses are returned in the order they are passed in. We print the 
#' first 10.
#' @examples \dontrun{
#' cc <- Async$new(
#'   urls = c(
#'     'https://httpbin.org/',
#'     'https://httpbin.org/get?a=5',
#'     'https://httpbin.org/get?foo=bar'
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
#' 
#' # using auth with async
#' dd <- Async$new(urls = rep('https://httpbin.org/basic-auth/user/passwd', 3))
#' res <- dd$get(auth = auth(user = "user", pwd = "passwd"))
#' res
#' vapply(res, function(z) z$status_code, double(1))
#' vapply(res, function(z) z$success(), logical(1))
#' lapply(res, function(z) z$parse("UTF-8"))
#' 
#' # failure behavior
#' ## e.g. when a URL doesn't exist, a timeout, etc.
#' urls <- c("http://stuffthings.gvb", "https://foo.com", 
#'   "https://httpbin.org/get")
#' conn <- Async$new(urls = urls)
#' res <- conn$get()
#' res[[1]]$parse("UTF-8") # a failure
#' res[[2]]$parse("UTF-8") # a failure
#' res[[3]]$parse("UTF-8") # a success
#' }
Async <- R6::R6Class(
  'Async',
  public = list(
    urls = NULL,

    print = function(x, ...) {
      cat("<crul async connection> ", sep = "\n")
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

    initialize = function(urls) {
      self$urls <- urls
    },

    get = function(path = NULL, query = list(), disk = NULL,
                   stream = NULL, ...) {
      private$gen_interface(self$urls, "get", path, query,
        disk = disk, stream = stream, ...)
    },

    post = function(path = NULL, query = list(), body = NULL,
                    encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "post", path, query, body, encode,
        disk, stream, ...)
    },

    put = function(path = NULL, query = list(), body = NULL,
                   encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "put", path, query, body, encode,
        disk, stream, ...)
    },

    patch = function(path = NULL, query = list(), body = NULL,
                     encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "patch", path, query, body, encode,
        disk, stream, ...)
    },

    delete = function(path = NULL, query = list(), body = NULL,
                      encode = "multipart", disk = NULL, stream = NULL, ...) {
      private$gen_interface(self$urls, "delete", path, query, body, encode,
        disk, stream, ...)
    },

    head = function(path = NULL, ...) {
      private$gen_interface(self$urls, "head", path, ...)
    }
  ),

  private = list(
    gen_interface = function(x, method, path, query = NULL, body = NULL,
      encode = NULL, disk = NULL, stream = NULL, auth = NULL, ...) {

      if (!is.null(disk)) {
        if (length(disk) > 1) {
          stopifnot(length(x) == length(disk))
          reqs <- Map(function(z, m) {
            switch(
              method,
              get = HttpRequest$new(url = z, auth = auth)$get(path = path, query = query,
                disk = m, stream = stream, ...),
              post = HttpRequest$new(url = z, auth = auth)$post(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              put = HttpRequest$new(url = z, auth = auth)$put(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              patch = HttpRequest$new(url = z, auth = auth)$patch(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              delete = HttpRequest$new(url = z, auth = auth)$delete(path = path,
                query = query, body = body, encode = encode, disk = m,
                stream = stream, ...),
              head = HttpRequest$new(url = z, auth = auth)$head(path = path, ...)
            )
          }, x, disk)
        }
      } else {
        reqs <- lapply(x, function(z) {
          switch(
            method,
            get = HttpRequest$new(url = z, auth = auth)$get(path = path, query = query,
              disk = disk, stream = stream, ...),
            post = HttpRequest$new(url = z, auth = auth)$post(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            put = HttpRequest$new(url = z, auth = auth)$put(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            patch = HttpRequest$new(url = z, auth = auth)$patch(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            delete = HttpRequest$new(url = z, auth = auth)$delete(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            head = HttpRequest$new(url = z, auth = auth)$head(path = path, ...)
          )
        })
      }
      tmp <- AsyncVaried$new(.list = reqs)
      tmp$request()
      tmp$responses()
    }
  )
)
