#' upload file
#'
#' @export
#' @param path (character) a single path, file must exist
#' @param type (character) a file type, guessed by [mime::guess_type] if
#' not given
#' @examples \dontrun{
#' # image
#' path <- file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg")
#' (x <- HttpClient$new(url = "https://eu.httpbin.org"))
#' res <- x$post(path = "post", body = list(y = upload(path)))
#' res$content
#'
#' # text file, in a list
#' file <- upload(system.file("CITATION"))
#' res <- x$post(path = "post", body = list(y = file))
#' jsonlite::fromJSON(res$parse("UTF-8"))
#'
#' # text file, as data
#' res <- x$post(path = "post", body = file)
#' jsonlite::fromJSON(res$parse("UTF-8"))
#' }
upload <- function(path, type = NULL) {
  stopifnot(is.character(path), length(path) == 1, file.exists(path))
  if (is.null(type)) type <- mime::guess_type(path)
  curl::form_file(path, type)
}
