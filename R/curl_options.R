nonacccurl <- c(
  "httpget",
  "httppost",
  "post",
  "postfields",
  "postfieldsize",
  "customrequest"
)

curl_opts_check <- function(...) {
  x <- list(...)
  if (any(names(x) %in% nonacccurl)) {
    stop(
      paste0(
        "the following curl options are not allowed:\n  ",
        paste(nonacccurl, collapse = ", ")
      ),
      call. = FALSE
    )
  }
}

#' curl verbose method
#' @export
#' @param data_out Show data sent to the server
#' @param data_in Show data recieved from the server
#' @param info Show informational text from curl. This is mainly useful for
#' debugging https and auth problems, so is disabled by default
#' @param ssl Show even data sent/recieved over SSL connections?
#' @note adapted from `httr::verbose`
#' @details
#' line prefixes:
#' - `*` informative curl messages
#' - `=>` headers sent (out)
#' - `>` data sent (out)
#' - `*>` ssl data sent (out)
#' - `<=` headers received (in)
#' - `<` data received (in)
#' - `<*` ssl data received (in)
curl_verbose <- function(
  data_out = TRUE,
  data_in = FALSE,
  info = FALSE,
  ssl = FALSE
) {
  pm <- function(prefix, x, blank_line = FALSE) {
    x <- readBin(x, character())
    lines <- unlist(strsplit(x, "\n", fixed = TRUE, useBytes = TRUE))
    out <- paste0(prefix, lines, collapse = "\n")
    message(out)
    if (blank_line) cat("\n")
  }
  function(type, msg) {
    switch(
      type + 1,
      text = if (info) pm("*  ", msg),
      headerIn = pm("<= ", msg),
      headerOut = pm("=> ", msg),
      dataIn = if (data_in) pm("<  ", msg, TRUE),
      dataOut = if (data_out) pm("> ", msg, TRUE),
      sslDataIn = if (ssl && data_in) pm("*< ", msg, TRUE),
      sslDataOut = if (ssl && data_out) pm("*> ", msg, TRUE)
    )
  }
}
