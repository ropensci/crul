#' progress bar helper
#'
#' @name progress
#' @details uses `httr::progress()` and pulls out that info 
#' to pass down to \pkg{curl}
#' 
#' if file sizes known you get progress bar; if file sizes not 
#' known you get bytes downloaded
#' @examples
#' (x <- HttpClient$new(
#'   url = "https://httpbin.org/bytes/102400", 
#'   progress = httr::progress()
#' ))
#' z <- x$get()
#' w <- x$post()
#' 
#' # with Paginator - Crossref API
#' (cli <- HttpClient$new(url = "https://api.crossref.org", 
#'   progress = httr::progress()))
#' cc <- Paginator$new(client = cli, limit_param = "rows",
#'    offset_param = "offset", limit = 50, limit_chunk = 10)
#' cc
#' cc$get('works')
#' cc$responses()
#' 
#' # with Paginator - GBIF API
#' (cli <- HttpClient$new(url = "https://api.gbif.org", 
#'   progress = httr::progress()))
#' cc <- Paginator$new(client = cli, limit_param = "limit",
#'    offset_param = "offset", limit = 150, limit_chunk = 30)
#' cc
#' cc$get('v1/occurrence/search')
#' cc$responses()
NULL
