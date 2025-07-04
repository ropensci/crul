#' @section Failure behavior:
#' HTTP requests mostly fail in ways that you are probably familiar with,
#' including when there's a 400 response (the URL not found), and when the
#' server made a mistake (a 500 series HTTP status code).
#'
#' But requests can fail sometimes where there is no HTTP status code, and
#' no agreed upon way to handle it other than to just fail immediately.
#'
#' When a request fails when using synchronous requests (see [HttpClient])
#' you get an error message that stops your code progression
#' immediately saying for example:
#'
#' - "Could not resolve host: https://foo.com"
#' - "Failed to connect to foo.com"
#' - "Resolving timed out after 10 milliseconds"
#'
#' However, for async requests we don't want to fail immediately because
#' that would stop the subsequent requests from occurring. Thus, when
#' we find that a request fails for one of the reasons above we
#' give back a [HttpResponse] object just like any other response, and:
#'
#' - capture the error message and put it in the `content` slot of the
#' response object (thus calls to `content` and `parse()` work correctly)
#' - give back a `0` HTTP status code. we handle this specially when testing
#' whether the request was successful or not with e.g., the `success()`
#' method
