#' Working with HTTP headers
#'
#' @name http-headers
#' @examples \dontrun{
#' (x <- HttpClient$new(url = "https://hb.opencpu.org"))
#'
#' # set headers
#' (res <- HttpClient$new(
#'   url = "https://hb.opencpu.org",
#'   opts = list(
#'     verbose = TRUE
#'   ),
#'   headers = list(
#'     a = "stuff",
#'     b = "things"
#'   )
#' ))
#' res$headers
#' # reassign header value
#' res$headers$a <- "that"
#' # define new header
#' res$headers$c <- "what"
#' # request
#' res$get('get')
#'
#' ## setting content-type via headers
#' (res <- HttpClient$new(
#'   url = "https://hb.opencpu.org",
#'   opts = list(
#'     verbose = TRUE
#'   ),
#'   headers = list(`Content-Type` = "application/json")
#' ))
#' res$get('get')
#' }
NULL
