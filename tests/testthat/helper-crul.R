hb <- function(x = NULL) {
  tryCatch(
    if (is.null(x)) base_url else paste0(base_url, x),
    error = function(e) "https://not.aurl"
  )
}

# check various httpbin servers
urls <- c(
  "https://hb.opencpu.org",
  "https://nghttp2.org/httpbin"
)
h <- curl::new_handle(timeout = 10, failonerror = FALSE)
tryCatch({
  out <- list()
  for (i in seq_along(urls)) {
    out[[i]] <- curl::curl_fetch_memory(urls[i], handle = h)
  }
  codes <- vapply(out, "[[", 1, "status_code")
  if (all(codes != 200)) stop("all httpbin servers down")
  base_url <- urls[codes == 200][1]
  cat(paste0("using base url for tests: ", base_url), sep = "\n")
}, error = function(e) message(e$message))
