# if on travis use docker httpbin via localhost:80 
# if not on travis use web httpbin via httpbin.org

if (identical(Sys.getenv("TRAVIS"), "true")) {
  base_url <- "http://localhost:80"
} else {
  # if using web version, check if its up first
  base_url <- "https://httpbin.org"
  h <- curl::new_handle(timeout = 10, failonerror = TRUE)
  curl::curl("https://httpbin.org", handle = h)
}
