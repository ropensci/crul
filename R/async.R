#' Simple async client
#'
#' A client to work with many URLs, but all with the same HTTP method
#'
#' @export
#' @param urls (character) one or more URLs (required)
#' @family async
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
#' Responses are returned in the order they are passed in.
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
#' }
Async <- R6::R6Class(
  'Async',
  public = list(
    urls = NULL,

    print = function(x, ...) {
      cat("<crul async connection> ", sep = "\n")
      cat("  urls: ", sep = "\n")
      for (i in seq_along(self$urls)) {
        cat(paste0("   ", self$urls[[i]]), sep = "\n")
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
      encode = NULL, disk = NULL, stream = NULL, ...) {

      if (!is.null(disk)) {
        if (length(disk) > 1) {
          stopifnot(length(x) == length(disk))
          reqs <- Map(function(z, m) {
            switch(
              method,
              get = HttpRequest$new(url = z)$get(path = path, query = query,
                disk = m, stream = stream, ...),
              post = HttpRequest$new(url = z)$post(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              put = HttpRequest$new(url = z)$put(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              patch = HttpRequest$new(url = z)$patch(path = path, query = query,
                body = body, encode = encode, disk = m, stream = stream,
                ...),
              delete = HttpRequest$new(url = z)$delete(path = path,
                query = query, body = body, encode = encode, disk = m,
                stream = stream, ...),
              head = HttpRequest$new(url = z)$head(path = path, ...)
            )
          }, x, disk)
        }
      } else {
        reqs <- lapply(x, function(z) {
          switch(
            method,
            get = HttpRequest$new(url = z)$get(path = path, query = query,
              disk = disk, stream = stream, ...),
            post = HttpRequest$new(url = z)$post(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            put = HttpRequest$new(url = z)$put(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            patch = HttpRequest$new(url = z)$patch(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            delete = HttpRequest$new(url = z)$delete(path = path, query = query,
              body = body, encode = encode, disk = disk, stream = stream, ...),
            head = HttpRequest$new(url = z)$head(path = path, ...)
          )
        })
      }
      tmp <- AsyncVaried$new(.list = reqs)
      tmp$request()
      tmp$responses()
    }
  )
)
