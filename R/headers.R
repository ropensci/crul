head_parse <- function(z) {
  status <- list(status = sw(z[[1]]))
  hl <- z[z != ""][-1]
  ff <- regexec("^([^:]*):\\s*(.*)$", hl)
  xx <- regmatches(hl, ff)
  n <- vapply(xx, length, integer(1))
  if (any(n != 3)) {
    bad <- hl[n != 3]
    xx <- xx[n == 3]
    warning("Failed to parse headers:\n", paste0(bad, "\n"), call. = FALSE)
  }
  names <- tolower(vapply(xx, "[[", 2, FUN.VALUE = character(1)))
  values <- lapply(xx, "[[", 3)
  c(status, as.list(stats::setNames(values, names)))
}
