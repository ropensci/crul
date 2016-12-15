nonacccurl <- c("httpget", "httppost", "post", "postfields",
                "postfieldsize", "customrequest")

curl_opts_check <- function(...) {
  x <- list(...)
  if (any(names(x) %in% nonacccurl)) {
    stop(
      paste0("the following curl options are not allowed:\n  ",
             paste(nonacccurl, collapse = ", ")),
      call. = FALSE
    )
  }
}
