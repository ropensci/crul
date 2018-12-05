make_type <- function(x) {
  if (is.null(x))  {
    return()
  }
  if (substr(x, 1, 1) == ".") {
    x <- mime::guess_type(x, empty = NULL)
  }
  list(`Content-Type` = x)
}

# adapted from https://github.com/hadley/httr
raw_body <- function(body, type = NULL) {
  if (is.character(body)) {
    body <- charToRaw(paste(body, collapse = "\n"))
  }
  stopifnot(is.raw(body))
  list(
    opts = list(
      post = TRUE,
      postfieldsize = length(body),
      postfields = body
    ),
    type = make_type(type %||% "")
  )
}

# adapted from https://github.com/hadley/httr
prep_body <- function(body, encode, type = NULL) {
  if (identical(body, FALSE)) {
    return(list(opts = list(post = TRUE, nobody = TRUE)))
  }
  if (is.character(body) || is.raw(body)) {
    return(raw_body(body, type = type))
  }
  if (inherits(body, "form_file")) {
    filePath <- body$path
    size <- file.info(filePath)$size
    con <- NULL
    return(
      list(
        opts = list(
          post = TRUE,
          readfunction = function(nbytes, ...) {
            if (is.null(con)) con <<- file(filePath, "rb")
            if (is.null(con)) return(raw())
            bin <- readBin(con, "raw", nbytes)
            if (length(bin) < nbytes) {
              close(con)
              con <<- NULL
            }
            bin
          },
          postfieldsize_large = size
        ),
        type = make_type(body$type)
      )
    )
  }
  if (is.null(body)) {
    return(raw_body(raw()))
  }
  if (!is.list(body)) {
    stop("Unknown type of `body`: must be NULL, FALSE, character, raw or list",
         call. = FALSE)
  }

  body <- ccp(body)
  if (!encode %in% c('raw', 'form', 'json', 'multipart')) {
    stop("encode must be one of raw, form, json, or multipart", call. = FALSE)
  }

  if (encode == "raw") {
    raw_body(body)
  } else if (encode == "form") {
    raw_body(make_query(body), "application/x-www-form-urlencoded")
  } else if (encode == "json") {
    raw_body(jsonlite::toJSON(body, auto_unbox = TRUE), "application/json")
  } else if (encode == "multipart") {
    if (!all(has_name(body))) {
      stop("All components of body must be named", call. = FALSE)
    }
    list(
      opts = list(
        post = TRUE
      ),
      fields = lapply(body, as.character)
    )
  }
}
