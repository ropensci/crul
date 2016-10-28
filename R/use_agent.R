make_ua <- function() {
  versions <- c(
    libcurl = curl::curl_version()$version,
    `r-curl` = as.character(utils::packageVersion("curl")),
    crul = as.character(utils::packageVersion("crul"))
  )
  paste0(names(versions), "/", versions, collapse = " ")
}
