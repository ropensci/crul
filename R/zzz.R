make_url <- function(url = NULL, handle = NULL, path, query) {
  if (!is.null(handle)) {
    url <- handle$url
  } else {
    handle <- list(handle = curl::new_handle())
  }

  if (!is.null(path)) {
    urltools::path(url) <- path
  }

  url <- gsub("\\s", "%20", url)

  url <- add_query(query, url)
  # if (length(query)) {
    # for (i in seq_along(query)) {
    #   url <- urltools::param_set(url, names(query)[i], query[[i]])
    # }
  # }

  return(list(url = url, handle = handle$handle))
}

# query <- list(a = 5, a = 6)
# query <- list(a = 5)
# query <- list()
# add_query(query, "https://httpbin.org")
add_query <- function(x, url) {
  if (length(x)) {
    quer <- list()
    for (i in seq_along(x)) {
      quer[[i]] <- paste(names(x)[i], urltools::url_encode(x[[i]]), sep = "=")
    }
    parms <- paste0(quer, collapse = "&")
    paste0(url, "?", parms)
  } else {
    return(url)
  }
}

head_parse <- function(z) {
  if (grepl("HTTP\\/", z)) {
    list(status = z)
  } else {
    ff <- regexec("^([^:]*):\\s*(.*)$", z)
    xx <- regmatches(z, ff)[[1]]
    as.list(stats::setNames(xx[[3]], tolower(xx[[2]])))
  }
}

headers_parse <- function(x) do.call("c", lapply(x, head_parse))
