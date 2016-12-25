#' HTTP POST requests
#'
#' @name post-requests
#' @examples
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#'
#' # post request
#' (res_post <- x$post('post', body = list(hello = "world")))
#'
#' ## empty body request
#' x$post('post')
#'
#' ## form requests
#' (cli <- HttpClient$new(
#'   url = "http://apps.kew.org/wcsp/advsearch.do"
#' ))
#' cli$post(
#'   encode = "form",
#'   body = list(
#'     page = 'advancedSearch',
#'     genus = 'Gagea',
#'     species = 'pratensis',
#'     selectedLevel = 'cont'
#'   )
#' )
#'
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' res <- x$post("post",
#'   encode = "json",
#'   body = list(
#'     genus = 'Gagea',
#'     species = 'pratensis'
#'   )
#' )
#' jsonlite::fromJSON(res$parse())
#'
#'
#' # path <- file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg")
#' # (x <- HttpClient$new(url = "https://httpbin.org"))
#' # x$post("post",
#' #    body = list(
#' #      files = list(path = path)
#' #    )
#' # )
#'
NULL
