# modified from: https://github.com/r-lib/httr/blob/master/R/progress.R
# license: MIT

#' progress bar
#'
#' @param type Type of progress to display: either number of bytes uploaded
#'   or downloaded. one of "up" or "down" (default)
#' @param con Connection to send output too. Usually [stdout()] or
#'    [stderr()]
#' @export
#' @examples
#' (x <- HttpClient$new(
#'   url = "https://httpbin.org/bytes/102400", 
#'   progress = progress_bar()
#' ))
#' z <- x$get()
#' w <- x$post()
#' 
#' # with pkg progress
#' (x <- HttpClient$new(
#'   url = "https://httpbin.org/bytes/102400", 
#'   progress = progress_bar()
#' ))
#' x$progress
#' z <- x$get()
#' 
#' # with Paginator - Crossref API
#' (cli <- HttpClient$new(url = "https://api.crossref.org", 
#'   progress = progress_bar()))
#' cc <- Paginator$new(client = cli, limit_param = "rows",
#'    offset_param = "offset", limit = 50, limit_chunk = 10)
#' cc
#' cc$get('works')
#' cc$responses()
#' 
#' # with Paginator - GBIF API
#' (cli <- HttpClient$new(url = "https://api.gbif.org", 
#'   progress = progress_bar()))
#' cc <- Paginator$new(client = cli, limit_param = "limit",
#'    offset_param = "offset", limit = 150, limit_chunk = 30)
#' cc
#' cc$get('v1/occurrence/search')
#' cc$responses()
#' }
progress_bar <- function(type = "down", con = stdout()) {
  stopifnot(type %in% c("down", "up"))

  # httr:::request(options = list(
  #   noprogress = FALSE,
  #   progressfunction = progress(type, con)
  # ))

  list(options = list(
    noprogress = FALSE,
    progressfunction = prog()
  ))
}

# modified from: https://github.com/r-lib/httr/blob/master/R/progress.R
# license: MIT
progress <- function(type, con) {
  bar <- NULL

  show_progress <- function(down, up) {
    if (type == "down") {
      total <- down[[1]]
      now <- down[[2]]
    } else {
      total <- up[[1]]
      now <- up[[2]]
    }

    if (total == 0 && now == 0) {
      # Reset progress bar when seeing first byte
      bar <<- NULL
    } else if (total == 0) {
      cat("\rDownloading: ", bytes(now, digits = 2), "     ", sep = "", file = con)
      utils::flush.console()
      # Can't automatically add newline on completion because there's no
      # way to tell when then the file has finished downloading
    } else {
      if (is.null(bar)) {
        bar <<- utils::txtProgressBar(max = total, style = 3, file = con)
      }
      utils::setTxtProgressBar(bar, now)
      if (now == total) close(bar)
    }

    TRUE
  }

  show_progress
}

# modified from: https://github.com/r-lib/httr/blob/master/R/progress.R
# license: MIT
bytes <- function(x, digits = 3, ...) {
  power <- min(floor(log(abs(x), 1000)), 4)
  if (power < 1) {
    unit <- "B"
  } else {
    unit <- c("kB", "MB", "GB", "TB")[[power]]
    x <- x / (1000 ^ power)
  }

  formatted <- format(signif(x, digits = digits), big.mark = ",",
    scientific = FALSE)

  paste0(formatted, " ", unit)
}


library(progress)
prog <- function(con = stdout()) {
  # bar <- NULL
  bar <- progress::progress_bar$new()
  bar$tick(0)

  show_progress <- function(down, up) {
    total <- down[[1]]
    now <- down[[2]]

    bar$initialize(total = total)

    if (total == 0 && now == 0) {
      # Reset progress bar when seeing first byte
      bar <<- NULL
    } else if (total == 0) {
      cat("\rDownloading: ", bytes(now, digits = 2), "     ", sep = "", file = con)
      utils::flush.console()
      # Can't automatically add newline on completion because there's no
      # way to tell when then the file has finished downloading
    } else {
      if (is.null(bar)) {
        # bar <<- utils::txtProgressBar(max = total, style = 3, file = con)
        # bar <<- progress::progress_bar$new(total = total)
        # bar$tick(0)
      }
      # bar$tick(len = now)
      bar$tick()
      if (now == total) rm(bar)
    }

    TRUE
  }

  show_progress
}


# # pb <- progress_bar$new(total = 100)
# pb <- progress::progress_bar$new()
# f <- function() {
#   pb$tick(0)
#   Sys.sleep(3)
#   for (i in 1:100) {
#     pb$tick()
#     Sys.sleep(1 / 100)
#   }
# }
# f()
