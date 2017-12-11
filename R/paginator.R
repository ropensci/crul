#' Paginator client
#'
#' A client help you paginate, a wrapper around [HttpClient]
#'
#' @export
#' @param client an object of class `HttpClient`, from a call to [HttpClient]
#' @param by (character) how to paginate. One of query_params, link_headers, 
#' or cursor. See Details.
#' @param limit_param (character) the name of the limit parameter. 
#' Default: limit
#' @param offset_param (character) the name of the offset parameter. 
#' Default: offset
#' @param limit (numeric/integer) the maximum records wanted
#' @param limit_chunk (numeric/integer) the number by which to chunk requests,
#' e.g., 10 would be be each request gets 10 records
#' @details
#' **Methods**
#'   \describe{
#'     \item{`get(path, query, ...)`}{
#'       make a paginated GET request
#'     }
#'     \item{`post(path, query, body, encode, ...)`}{
#'       make a paginated POST request
#'     }
#'     \item{`put(path, query, body, encode, ...)`}{
#'       make a paginated PUT request
#'     }
#'     \item{`patch(path, query, body, encode, ...)`}{
#'       make a paginated PATCH request
#'     }
#'     \item{`delete(path, query, body, encode, ...)`}{
#'       make a paginated DELETE request
#'     }
#'     \item{`head(path, ...)`}{
#'       make a paginated HEAD request
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
#' See [HttpClient()] for information on parameters.
#'
#' @format NULL
#' @usage NULL
#' 
#' @section Methods to paginate:
#' 
#' - `query_params`: the most common way, so is the default. This method
#' involves setting how many records and what record to start at for each 
#' request. We send these query parameters for you.
#' - `link_headers`: link headers are URLS for the next/previous/last 
#' request given in the response header from the server. This is relatively
#' uncommon, though is recommended by JSONAPI and is implemented by a 
#' well known API (GitHub). 
#' - `cursor`: this works by a single string given back in each response, to
#' be passed in the subsequent response, and so on until no more records 
#' remain. This is common in Solr
#' 
#' @return a list, with objects of class [HttpResponse()].
#' Responses are returned in the order they are passed in.
#' 
#' @examples \dontrun{
#' # by query parameters (here limit and skip for CouchDB)
#' (cli <- HttpClient$new(url = "http://localhost:5984"))
#' cc <- Paginator$new(client = cli, by = "query_params", limit_param = "limit",
#'    offset_param = "skip", limit = 100, limit_chunk = 5)
#' cc
#' #cc$requests()
#' cli$get('omdb/_all_docs', query = list(limit = 3))$parse("UTF-8")
#' cc$get('omdb/_all_docs')
#' cc
#' cc$responses()
#' cc$status()
#' cc$status_code()
#' cc$times()
#' cc$content()
#' cc$parse()
#' lapply(cc$parse(), jsonlite::fromJSON)
#' 
#' # by link headers: GitHub
#' ## eg to come
#' 
#' # by cursor: Crossref
#' ## eg to come
#' }
Paginator <- R6::R6Class(
  'Pagintor',
  public = list(
    http_req = NULL,
    by = NULL,
    limit_chunk = NULL,
    limit_param = NULL,
    offset_param = NULL,
    limit = NULL,
    req = NULL,

    print = function(x, ...) {
      cat("<crul paginator> ", sep = "\n")
      cat(paste0("  by: ", self$by), sep = "\n")
      cat(paste0("  limit_chunk: ", self$limit_chunk), sep = "\n")
      cat(paste0("  limit_param: ", self$limit_param), sep = "\n")
      cat(paste0("  offset_param: ", self$offset_param), sep = "\n")
      cat(paste0("  limit: ", self$limit), sep = "\n")
      cat(paste0("  status: ", 
        if (length(private$resps) == 0) {
          "not run yet" 
        } else {
          paste0(length(private$resps), " requests done")
        }), sep = "\n")
      invisible(self)
    },

    initialize = function(client, by, limit_param, offset_param, limit, limit_chunk) {  
      self$http_req <- client
      if (!missing(by)) self$by <- by
      if (!missing(limit_chunk)) self$limit_chunk <- limit_chunk
      if (!missing(limit_param)) self$limit_param <- limit_param
      if (!missing(offset_param)) self$offset_param <- offset_param
      if (!missing(limit)) self$limit <- limit
      private$offset_iters <-  c(0, seq(from=0, to=self$limit, by=self$limit_chunk)[-1])
      private$offset_args <- as.list(stats::setNames(private$offset_iters, 
        rep(self$offset_param, length(private$offset_iters))))
    },

    requests = function() {
      message("not working yet")
      # req_name <- sub("\\$.+", "", deparse(self$req[[1]]$expr))
      # req_obj <- lazy_eval(req_name, data = self$req[[1]])
      # url <- req_obj$url
      # lim_each <- self$limit / self$limit_chunk
      # urls <- vector(mode = "character", length = lim_each)
      # cat("base url: ", url)
      # cat(sprintf("  requests: %s requests of %s records each", length(lim_each), self$limit_chunk), sep = "\n")
      # return(invisible())
    },

    # HTTP verbs
    get = function(path = NULL, query = list(), ...) {
      private$page("get", path, query, ...)
    },

    post = function(path = NULL, query = list(), body = NULL,
                    encode = "multipart", ...) {
      private$page("post", path, query, body, encode, ...)
    },

    put = function(path = NULL, query = list(), body = NULL,
                   encode = "multipart", ...) {
      private$page("put", path, query, body, encode, ...)
    },

    patch = function(path = NULL, query = list(), body = NULL,
                     encode = "multipart", ...) {
      private$page("patch", path, query, body, encode, ...)
    },

    delete = function(path = NULL, query = list(), body = NULL,
                      encode = "multipart", ...) {
      private$page("delete", path, query, body, encode, ...)
    },

    head = function(path = NULL, ...) {
      private$page("head", path, ...)
    },

    # functions to inspect output
    responses = function() {
      private$resps %||% list()
    },

    status_code = function() {
      vapply(private$resps, function(z) z$status_code, 1)
    },

    status = function() {
      lapply(private$resps, function(z) z$status_http())
    },

    parse = function(encoding = "UTF-8") {
      vapply(private$resps, function(z) z$parse(encoding = encoding), "")
    },

    content = function() {
      lapply(private$resps, function(z) z$content)
    },

    times = function() {
      lapply(private$resps, function(z) z$times)
    }
  ),

  private = list(
    offset_iters = NULL,
    offset_args = NULL,
    resps = NULL,
    page = function(method, path, query, ...) {
      tmp <- list()
      for (i in seq_along(private$offset_iters)) {
        off <- private$offset_args[i]
        off[self$limit_param] <- self$limit_chunk
        tmp[[i]] <- switch(
          method,
          get = self$http_req$get(path, query = ccp(c(query, off)), ...),
          post = self$http_req$post(...),
          put = self$http_req$put(...),
          patch = self$http_req$patch(...),
          delete = self$http_req$delete(...),
          head = self$http_req$head(...)
        )
      }
      private$resps <- tmp
      cat("OK", sep = "\n")
    }
  )
)
