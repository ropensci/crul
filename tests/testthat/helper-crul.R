# skip_on_cran()

hb <- function(x = NULL) if (is.null(x)) base_url else paste0(base_url, x)

# check various httpbin servers
urls <- c(
  "https://hb.opencpu.org",
  "https://nghttp2.org/httpbin"
)
h <- curl::new_handle(timeout = 10, failonerror = FALSE)
out <- list()
for (i in seq_along(urls)) {
  tryCatch({
    out[[i]] <- curl::curl_fetch_memory(urls[i], handle = h)
  }, error = function(e)
    message(urls[i], " is down ", e$message)
  )
}
codes <- vapply(out, "[[", 1, "status_code")
if (!any(codes == 200)) stop("all httpbin servers down")
base_url <- urls[codes == 200][1]
cat(paste0("using base url for tests: ", base_url), sep = "\n")
