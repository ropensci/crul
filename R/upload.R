#' upload file
#'
#' @export
#' @param path (character) a single path, file must exist
#' @param type (character) a file type, guessed by [mime::guess_type] if
#' not given
upload <- function(path, type = NULL) {
  stopifnot(is.character(path), length(path) == 1, file.exists(path))
  if (is.null(type)) type <- mime::guess_type(path)
  curl::form_file(path, type)
}
