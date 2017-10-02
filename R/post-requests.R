#' HTTP POST/PUT/PATCH requests
#'
#' @name post-requests
#' @examples
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#'
#' # POST requests
#' ## a list
#' (res_post <- x$post('post', body = list(hello = "world"), verbose = TRUE))
#'
#' ## a string
#' (res_post <- x$post('post', body = "hello world", verbose = TRUE))
#'
#' ## empty body request
#' x$post('post')
#'
#' ## form requests
#' \dontrun{
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
#' }
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
#' # PUT requests
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' (res <- x$put(path = "put",
#'   encode = "json",
#'   body = list(
#'     genus = 'Gagea',
#'     species = 'pratensis'
#'   )
#' ))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' res <- x$put("put", body = "foo bar")
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#'
#' # PATCH requests
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' (res <- x$patch(path = "patch",
#'   encode = "json",
#'   body = list(
#'     genus = 'Gagea',
#'     species = 'pratensis'
#'   )
#' ))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' res <- x$patch("patch", body = "foo bar")
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#'
#' # Upload files
#' path <- file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg")
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' res <- x$post(path = "post", body = list(y = upload(path)))
#' res$content
#'
#' (x <- HttpClient$new(url = "https://httpbin.org"))
#' file <- upload(system.file("CITATION"))
#' res <- x$post(path = "post", body = list(y = file))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' # FIXME, can't pass file not in a list
#' # res <- x$post(path = "post", body = file)
#' # jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' file <- system.file("examples", "books2.json", package = "solrium")
#' (x <- HttpClient$new(url = "https://httpbin.org", opts = list(verbose = TRUE)))
#' res <- x$post(path = "post", body = upload(file))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' cli <- HttpClient$new(url = "http://127.0.0.1:8983", opts = list(verbose = TRUE))
#' res <- cli$post("solr/books/update/json/docs", body = upload(file))
#' jsonlite::fromJSON(res$parse("UTF-8"))
NULL
