make_url <- function(url = NULL, handle = NULL, path, query) {
  if (!is.null(handle)) {
    url <- handle$url
  } else {
    handle <- list(handle = curl::new_handle())
  }

  if (!is.null(path)) {
    urltools::path(url) <- path
  }

  if (length(query)) {
    for (i in seq_along(query)) {
      url <- urltools::param_set(url, names(query)[i], query[[i]])
    }
  }

  return(list(url = url, handle = handle$handle))
}
