#' Writing data options
#'
#' @name writing-options
#' @examples
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#'
#' # write to disk
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' f <- tempfile()
#' res <- x$get(disk = f)
#' res$content # when using write to disk, content is a path
#' readLines(res$content)
#'
#' # streaming response
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' res <- x$get('stream/50', stream = function(x) cat(rawToChar(x)))
#' res$content # when streaming, content is NULL
NULL
