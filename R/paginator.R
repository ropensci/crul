by_options <- c("limit_offset", "page_perpage")

#' @title Paginator client
#' @description A client to help you paginate
#'
#' @export
#' @template r6
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
#' @details See [HttpClient()] for information on parameters
#' @section Methods to paginate:
#'
#' Supported now:
#'
#' - `limit_offset`: the most common way (in my experience), so is the default.
#' This method involves setting how many records and what record to start at
#' for each request. We send these query parameters for you.
#' - `page_perpage`: set the page to fetch and (optionally) how many records
#' to get per page
#'
#' Supported later, hopefully:
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
#' if (interactive()) {
#' # limit/offset approach
#' con <- HttpClient$new(url = "https://api.crossref.org")
#' cc <- Paginator$new(client = con, limit_param = "rows",
#'    offset_param = "offset", limit = 50, chunk = 10)
#' cc
#' cc$get('works')
#' cc
#' cc$responses()
#' cc$status()
#' cc$status_code()
#' cc$times()
#' # cc$content()
#' cc$parse()
#' lapply(cc$parse(), jsonlite::fromJSON)
#' 
#' # page/per page approach (with no per_page param allowed)
#' conn <- HttpClient$new(url = "https://discuss.ropensci.org")
#' cc <- Paginator$new(client = conn, by = "page_perpage",
#'  page_param = "page", per_page_param = "per_page", limit = 90, chunk = 30)
#' cc
#' cc$get('c/usecases/l/latest.json')
#' cc$responses()
#' lapply(cc$parse(), jsonlite::fromJSON)
#' 
#' # page/per_page
#' conn <- HttpClient$new('https://api.inaturalist.org')
#' cc <- Paginator$new(conn, by = "page_perpage", page_param = "page",
#'  per_page_param = "per_page", limit = 90, chunk = 30)
#' cc
#' cc$get('v1/observations', query = list(taxon_name="Helianthus"))
#' cc$responses()
#' res <- lapply(cc$parse(), jsonlite::fromJSON)
#' res[[1]]$total_results
#' vapply(res, "[[", 1L, "page")
#' vapply(res, "[[", 1L, "per_page")
#' vapply(res, function(w) NROW(w$results), 1L)
#' ## another
#' ccc <- Paginator$new(conn, by = "page_perpage", page_param = "page",
#'  per_page_param = "per_page", limit = 500, chunk = 30, progress = TRUE)
#' ccc
#' ccc$get('v1/observations', query = list(taxon_name="Helianthus"))
#' res2 <- lapply(ccc$parse(), jsonlite::fromJSON)
#' vapply(res2, function(w) NROW(w$results), 1L)
#'
#' # progress bar
#' (con <- HttpClient$new(url = "https://api.crossref.org"))
#' cc <- Paginator$new(client = con, limit_param = "rows",
#'    offset_param = "offset", limit = 50, chunk = 10,
#'    progress = TRUE)
#' cc
#' cc$get('works')
#' }}
Paginator <- R6::R6Class(
  'Paginator',
  public = list(
    #' @field http_req an object of class `HttpClient`
    http_req = NULL,
    #' @field by (character) how to paginate. Only 'limit_offset' supported
    #' for now. In the future will support 'link_headers' and 'cursor'.
    #' See Details.
    by = "limit_offset",
    #' @field chunk (numeric/integer) the number by which to chunk
    #' requests, e.g., 10 would be be each request gets 10 records. 
    #' number is passed through [format()] to prevent larger numbers
    #' from being scientifically formatted
    chunk = NULL,
    #' @field limit_param (character) the name of the limit parameter.
    #' Default: limit
    limit_param = NULL,
    #' @field offset_param (character) the name of the offset parameter.
    #' Default: offset
    offset_param = NULL,
    #' @field limit (numeric/integer) the maximum records wanted.
    #' number is passed through [format()] to prevent larger numbers
    #' from being scientifically formatted
    limit = NULL,
    #' @field page_param (character) the name of the page parameter.
    #' Default: NULL
    page_param = NULL,
    #' @field per_page_param (character) the name of the per page parameter.
    #' Default: NULL
    per_page_param = NULL,
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
      cat(paste0("  chunk: ", self$chunk %||% "<none>"), sep = "\n")
      cat(paste0("  limit_param: ", self$limit_param %||% "<none>"), sep = "\n")
      cat(paste0("  offset_param: ", self$offset_param %||% "<none>"), sep = "\n")
      cat(paste0("  limit: ", self$limit %||% "<none>"), sep = "\n")
      cat(paste0("  page_param: ", self$page_param %||% "<none>"), sep = "\n")
      cat(paste0("  per_page_param: ", self$per_page_param %||% "<none>"), sep = "\n")
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
    #' @param by (character) how to paginate. Only 'limit_offset' supported for
    #' now. In the future will support 'link_headers' and 'cursor'. See Details.
    #' @param limit_param (character) the name of the limit parameter.
    #' Default: limit
    #' @param offset_param (character) the name of the offset parameter.
    #' Default: offset
    #' @param limit (numeric/integer) the maximum records wanted
    #' @param chunk (numeric/integer) the number by which to chunk requests,
    #' e.g., 10 would be be each request gets 10 records
    #' @param page_param (character) the name of the page parameter.
    #' @param per_page_param (character) the name of the per page parameter.
    #' @param progress (logical) print a progress bar, using [utils::txtProgressBar].
    #' Default: `FALSE`.
    #' @return A new `Paginator` object
    initialize = function(client, by = "limit_offset", limit_param = NULL,
      offset_param = NULL, limit = NULL, chunk = NULL,
      page_param = NULL, per_page_param = NULL, progress = FALSE) {

      ## checks
      if (!inherits(client, "HttpClient")) stop("'client' has to be an object of class 'HttpClient'",
        call. = FALSE)
      self$http_req <- client
      if (by == "query_params") {
        warning("by='query_params' has been changed to 'limit_offset'", call.=FALSE)
        by <- "limit_offset"
      }
      if (!by %in% by_options) {
        stop("'by' must be one of: ", paste0(by_options, collapse = ", "),
          call. = FALSE)
      }
      self$by <- by
      if (!missing(chunk)) {
        assert(chunk, c("numeric", "integer"))
        if (chunk < 1 || chunk %% 1 != 0) stop("'chunk' must be an integer and > 0")
      }
      self$chunk <- chunk
      if (!missing(limit_param)) assert(limit_param, "character")
      self$limit_param <- limit_param
      if (!missing(offset_param)) assert(offset_param, "character")
      self$offset_param <- offset_param
      if (!missing(limit)) {
        assert(limit, c("numeric", "integer"))
        if (!is.null(chunk)) {
          if (chunk %% 1 != 0) stop("'limit' must be an integer")
        }
      }
      self$limit <- limit
      assert(progress, "logical")
      self$progress <- progress

      if (!missing(page_param)) assert(page_param, "character")
      self$page_param <- page_param
      if (!missing(per_page_param)) assert(per_page_param, "character")
      self$per_page_param <- per_page_param

      if (self$by == "limit_offset") {
        # calculate pagination values
        private$offset_iters <-  c(0, seq(from=0, to=fround(self$limit, 10),
          by=self$chunk)[-1])
        private$offset_args <- as.list(stats::setNames(private$offset_iters,
          rep(self$offset_param, length(private$offset_iters))))
        private$limit_chunks <- rep(self$chunk, length(private$offset_iters))
        diffy <- self$limit - private$offset_iters[length(private$offset_iters)]
        if (diffy != self$chunk) {
          private$limit_chunks[length(private$limit_chunks)] <- diffy
        }
      }

      if (self$by == "page_perpage") {
        if (is.null(self$chunk)) {
          self$chunk <- if (!is.null(self$per_page_param)) {
            self$per_page_param
          } else {
            stop("if `per_page_param` is NULL, you must set `chunk`",
              call.=FALSE)
          }
        }

        private$offset_iters <- c(0, seq(from=0, to=fround(self$limit, 10),
          by=self$chunk)[-1])
        private$offset_args <- as.list(stats::setNames(1:length(private$offset_iters), 
          rep(self$page_param, length(private$offset_iters))))
        if (!is.null(self$per_page_param)) {
          pp <- as.list(stats::setNames(rep(self$chunk, length(private$offset_iters)),
            rep(self$per_page_param, length(private$offset_iters))))
          for (i in seq_along(pp)) private$offset_args[[i]] <- c(private$offset_args[i], pp[i])
          private$offset_args <- unname(private$offset_args)
        } else {
          for (i in seq_along(private$offset_args)) private$offset_args[i] <- list(private$offset_args[i])
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
    #'    offset_param = "offset", limit = 50, chunk = 10)
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
      if (self$by == "limit_offset") {
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
      }
      if (self$by == "page_perpage") {
        for (i in seq_along(private$offset_iters)) {
          if (self$progress) utils::setTxtProgressBar(pb, i)
          off <- private$offset_args[[i]]
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
