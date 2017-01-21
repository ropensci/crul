crul_fetch <- function(x) {
  if (is.null(x$disk) && is.null(x$stream)) {
    # memory
    curl::curl_fetch_memory(x$url$url, handle = x$url$handle)
  } else if (!is.null(x$disk)) {
    # disk
    curl::curl_fetch_disk(x$url$url, x$disk, handle = x$url$handle)
  } else {
    # stream
    curl::curl_fetch_stream(x$url$url, x$stream, handle = x$url$handle)
  }
}
