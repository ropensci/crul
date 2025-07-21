#' Mocking HTTP requests
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Mocking is now controlled by params within the various clients:
#' [HttpClient()], [Async()] and [AsyncVaried()]
#'
#' @export
#' @param on (logical) turn mocking on with `TRUE` or turn off with `FALSE`.
#' By default is `FALSE`
mock <- function(on = TRUE) {
  lifecycle::deprecate_warn("1.6.0", "mock()")
  invisible(NULL)
}

as_mock_fun <- function(mock, error_call = caller_env()) {
  if (is.null(mock) || is.function(mock)) {
    mock
  } else {
    abort("mock must be NULL or a function")
  }
}
