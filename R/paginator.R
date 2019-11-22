#' @title Paginator client
#' @description A client to help you paginate
#'
#' @export
#' @param path URL path, appended to the base URL
#' @param query query terms, as a named list
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
#' @details See [HttpClient()] for information on parameters
#' @section Methods to paginate:
#'
#' Supported now:
#'
#' - `query_params`: the most common way, so is the default. This method
#' involves setting how many records and what record to start at for each
#' request. We send these query parameters for you.
#'
#' Supported later:
#'
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
#' (cli <- HttpClient$new(url = "https://api.crossref.org"))
#' cc <- Paginator$new(client = cli, limit_param = "rows",
#'    offset_param = "offset", limit = 50, limit_chunk = 10)
#' cc
#' cc$get('works')
#' cc
#' cc$responses()
#' cc$status()
#' cc$status_code()
#' cc$times()
#' cc$content()
#' cc$parse()
#' lapply(cc$parse(), jsonlite::fromJSON)
#'
#' # progress bar
#' (cli <- HttpClient$new(url = "https://api.crossref.org"))
#' cc <- Paginator$new(client = cli, limit_param = "rows",
#'    offset_param = "offset", limit = 50, limit_chunk = 10,
#'    progress = TRUE)
#' cc
#' cc$get('works')
#' }
Paginator <- R6::R6Class(
  'Paginator',
  public = list(
    #' @field http_req an object of class `HttpClient`
    http_req = NULL,
    #' @field by (character) how to paginate. Only 'query_params' supported
    #' for now. In the future will support 'link_headers' and 'cursor'.
    #' See Details.
    by = "query_params",
    #' @field limit_chunk (numeric/integer) the number by which to chunk
    #' requests, e.g., 10 would be be each request gets 10 records
    limit_chunk = NULL,
    #' @field limit_param (character) the name of the limit parameter.
    #' Default: limit
    limit_param = NULL,
    #' @field offset_param (character) the name of the offset parameter.
    #' Default: offset
    offset_param = NULL,
    #' @field limit (numeric/integer) the maximum records wanted
    limit = NULL,
    #' @field progress (logical) print a progress bar, using [utils::txtProgressBar].
    #' Default: `FALSE`.
    progress = FALSE,

    #' @description print method for `Paginator` objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat("<crul paginator> ", sep = "\n")
      cat(paste0(
        "  base url: ",
        if (is.null(self$http_req)) self$http_req$handle$url else self$http_req$url),
        sep = "\n")
      cat(paste0("  by: ", self$by), sep = "\n")
      cat(paste0("  limit_chunk: ", self$limit_chunk %||% "<none>"), sep = "\n")
      cat(paste0("  limit_param: ", self$limit_param %||% "<none>"), sep = "\n")
      cat(paste0("  offset_param: ", self$offset_param %||% "<none>"), sep = "\n")
      cat(paste0("  limit: ", self$limit %||% "<none>"), sep = "\n")
      cat(paste0("  progress: ", self$progress %||% ""), sep = "\n")
      cat(paste0("  status: ",
        if (length(private$resps) == 0) {
          "not run yet"
        } else {
          paste0(length(private$resps), " requests done")
        }), sep = "\n")
      invisible(self)
    },

    #' @description Create a new `Paginator` object
    #' @param client an object of class `HttpClient`, from a call to [HttpClient]
    #' @param by (character) how to paginate. Only 'query_params' supported for
    #' now. In the future will support 'link_headers' and 'cursor'. See Details.
    #' @param limit_param (character) the name of the limit parameter.
    #' Default: limit
    #' @param offset_param (character) the name of the offset parameter.
    #' Default: offset
    #' @param limit (numeric/integer) the maximum records wanted
    #' @param limit_chunk (numeric/integer) the number by which to chunk requests,
    #' e.g., 10 would be be each request gets 10 records
    #' @param progress (logical) print a progress bar, using [utils::txtProgressBar].
    #' Default: `FALSE`.
    #' @return A new `Paginator` object
    initialize = function(client, by = "query_params", limit_param,
      offset_param, limit, limit_chunk, progress = FALSE) {

      ## checks
      if (!inherits(client, "HttpClient")) stop("'client' has to be an object of class 'HttpClient'",
        call. = FALSE)
      self$http_req <- client
      if (by != "query_params") stop("'by' has to be 'query_params' for now",
        call. = FALSE)
      self$by <- by
      if (!missing(limit_chunk)) {
        assert(limit_chunk, c("numeric", "integer"))
        if (limit_chunk < 1 || limit_chunk %% 1 != 0) stop("'limit_chunk' must be an integer and > 0")
      }
      self$limit_chunk <- limit_chunk
      if (!missing(limit_param)) assert(limit_param, "character")
      self$limit_param <- limit_param
      if (!missing(offset_param)) assert(offset_param, "character")
      self$offset_param <- offset_param
      if (!missing(limit)) {
        assert(limit, c("numeric", "integer"))
        if (limit_chunk %% 1 != 0) stop("'limit' must be an integer")
      }
      self$limit <- limit
      assert(progress, "logical")
      self$progress <- progress

      if (self$by == "query_params") {
        # calculate pagination values
        private$offset_iters <-  c(0, seq(from=0, to=fround(self$limit, 10),
          by=self$limit_chunk)[-1])
        private$offset_args <- as.list(stats::setNames(private$offset_iters,
          rep(self$offset_param, length(private$offset_iters))))
        private$limit_chunks <- rep(self$limit_chunk, length(private$offset_iters))
        diffy <- self$limit - private$offset_iters[length(private$offset_iters)]
        if (diffy != self$limit_chunk) {
          private$limit_chunks[length(private$limit_chunks)] <- diffy
        }
      }
    },

    #' @description make a paginated GET request
    get = function(path = NULL, query = list(), ...) {
      private$page("get", path, query, ...)
    },

    #' @description make a paginated POST request
    post = function(path = NULL, query = list(), body = NULL,
                    encode = "multipart", ...) {
      private$page("post", path, query, body, encode, ...)
    },

    #' @description make a paginated PUT request
    put = function(path = NULL, query = list(), body = NULL,
                   encode = "multipart", ...) {
      private$page("put", path, query, body, encode, ...)
    },

    #' @description make a paginated PATCH request
    patch = function(path = NULL, query = list(), body = NULL,
                     encode = "multipart", ...) {
      private$page("patch", path, query, body, encode, ...)
    },

    #' @description make a paginated DELETE request
    delete = function(path = NULL, query = list(), body = NULL,
                      encode = "multipart", ...) {
      private$page("delete", path, query, body, encode, ...)
    },

    #' @description make a paginated HEAD request
    #' @details not sure if this makes any sense or not yet
    head = function(path = NULL, ...) {
      private$page("head", path, ...)
    },

    #' @description list responses
    #' @return a list of `HttpResponse` objects, empty list before requests made
    responses = function() {
      private$resps %||% list()
    },

    #' @description Get HTTP status codes for each response
    #' @return numeric vector, empty numeric vector before requests made
    status_code = function() {
      vapply(private$resps, function(z) z$status_code, 1)
    },

    #' @description List HTTP status objects
    #' @return a list of `http_code` objects, empty list before requests made
    status = function() {
      lapply(private$resps, function(z) z$status_http())
    },

    #' @description parse content
    #' @param encoding (character) the encoding to use in parsing.
    #' default:"UTF-8"
    #' @return character vector, empty character vector before
    #' requests made
    parse = function(encoding = "UTF-8") {
      vapply(private$resps, function(z) z$parse(encoding = encoding), "")
    },

    #' @description Get raw content for each response
    #' @return raw list, empty list before requests made
    content = function() {
      lapply(private$resps, function(z) z$content)
    },

    #' @description curl request times
    #' @return list of named numeric vectors, empty list before requests made
    times = function() {
      lapply(private$resps, function(z) z$times)
    },

    #' @description get the URL that would be sent (i.e., before executing
    #' the request) the only things that change the URL are path and query
    #' parameters; body and any curl options don't change the URL
    #' @return URLs (character)
    #' @examples \dontrun{
    #' cli <- HttpClient$new(url = "https://api.crossref.org")
    #' cc <- Paginator$new(client = cli, limit_param = "rows",
    #'    offset_param = "offset", limit = 50, limit_chunk = 10)
    #' cc$url_fetch('works')
    #' cc$url_fetch('works', query = list(query = "NSF"))
    #' }
    url_fetch = function(path = NULL, query = list()) {
      urls <- c()
      for (i in seq_along(private$offset_iters)) {
        off <- private$offset_args[i]
        off[self$limit_param] <- private$limit_chunks[i]
        urls[i] <- self$http_req$url_fetch(path, query = ccp(c(query, off)))
      }
      return(urls)
    }
  ),

  private = list(
    offset_iters = NULL,
    offset_args = NULL,
    limit_chunks = NULL,
    resps = NULL,
    page = function(method, path, query, body, encode, ...) {
      tmp <- list()
      if (self$progress) {
        pb <- utils::txtProgressBar(min = 0, max = length(private$offset_iters),
          initial = 0, style = 3)
        on.exit(close(pb), add = TRUE)
      }
      for (i in seq_along(private$offset_iters)) {
        if (self$progress) utils::setTxtProgressBar(pb, i)
        off <- private$offset_args[i]
        off[self$limit_param] <- private$limit_chunks[i]
        tmp[[i]] <- switch(
          method,
          get = self$http_req$get(path, query = ccp(c(query, off)), ...),
          post = self$http_req$post(path, query = ccp(c(query, off)),
            body = body, encode = encode, ...),
          put = self$http_req$put(path, query = ccp(c(query, off)),
            body = body, encode = encode, ...),
          patch = self$http_req$patch(path, query = ccp(c(query, off)),
            body = body, encode = encode, ...),
          delete = self$http_req$delete(path, query = ccp(c(query, off)),
            body = body, encode = encode, ...),
          head = self$http_req$head(path, ...)
        )
        # cat("\n")
      }
      private$resps <- tmp
      # message("OK\n")
    }
  )
)

# sttrim <- function(str) {
#   gsub("^\\s+|\\s+$", "", str)
# }

# parse_links <- function(w) {
#   if (is.null(w)) {
#     NULL
#   } else {
#     if (inherits(w, "character")) {
#       links <- sttrim(strsplit(w, ",")[[1]])
#       lapply(links, each_link)
#     } else {
#       nms <- sapply(w, "[[", "name")
#       tmp <- unlist(w[nms %in% "next"])
#       grep("http", tmp, value = TRUE)
#     }
#   }
# }

# each_link <- function(z) {
#   tmp <- sttrim(strsplit(z, ";")[[1]])
#   nm <- gsub("\"|(rel)|=", "", tmp[2])
#   url <- gsub("^<|>$", "", tmp[1])
#   list(name = nm, url = url)
# }
