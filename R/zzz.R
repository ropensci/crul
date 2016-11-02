make_url <- function(url, path, query) {
  if (!is.null(path)) {
    urltools::path(url) <- path
  }

  if (length(query)) {
    for (i in seq_along(query)) {
      url <- urltools::param_set(url, names(query)[i], query[[i]])
    }
  }

  return(url)
}

