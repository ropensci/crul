#' progress bar helper
#'
#' @name progress
#' @details uses `httr::progress()` and pulls out that info 
#' to pass down to \pkg{curl}
#' @examples
#' (x <- HttpClient$new(
#'   url = "https://httpbin.org/bytes/102400", 
#'   progress = httr::progress()
#' ))
#' z <- x$get()
#' w <- x$post()
NULL
