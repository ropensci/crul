# example for a custom debug function
upload_ftp <- function(file, url, verbose = TRUE){
  log <- rawConnection(raw(), 'r+')
  on.exit(close(log))
  stopifnot(file.exists(file))
  stopifnot(is.character(url))
  con <- file(file, open = "rb")
  on.exit(close(con))
  h <- curl::new_handle(upload = TRUE, filetime = FALSE, debugfunction = function(type, data){
    writeBin(data, log)
  })
  curl::handle_setopt(h, readfunction = function(n){
    readBin(con, raw(), n = n)
  }, verbose = verbose)
  try({
    curl::curl_fetch_memory(url, handle = h)
  })
  rawToChar(rawConnectionValue(log))
}
