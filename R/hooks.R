#' Event Hooks
#'
#' Trigger functions to run on requests and/or responses.
#' See Details for more.
#'
#' @name hooks
#' @details Functions passed to `request` are run **before** the
#' request occurs. The meaning of triggering a function on the
#' request is that you can do things to the request object.
#'
#' Functions passed to `response` are run **once** the
#' request is done, and the response object is created.
#' The meaning of triggering a function on the
#' response is to do things on the response object.
#'
#' The above for request and response applies the same
#' whether you make real HTTP requests or mock with
#' `webmockr`.
#' @note Only supported on [HttpClient] for now
#' @examples \dontrun{
#' # hooks on the request
#' fun_req <- function(request) {
#'   cat(paste0("Requesting: ", request$url$url), sep = "\n")
#' }
#' (x <- HttpClient$new(url = "https://hb.opencpu.org",
#'   hooks = list(request = fun_req)))
#' x$hooks
#' x$hooks$request
#' r1 <- x$get('get')
#'
#' captured_req <- list()
#' fun_req2 <- function(request) {
#'   cat("Capturing Request", sep = "\n")
#'   captured_req <<- request
#' }
#' (x <- HttpClient$new(url = "https://hb.opencpu.org",
#'   hooks = list(request = fun_req2)))
#' x$hooks
#' x$hooks$request
#' r1 <- x$get('get')
#' captured_req
#'
#'
#'
#' # hooks on the response
#' fun_resp <- function(response) {
#'   cat(paste0("status_code: ", response$status_code), sep = "\n")
#' }
#' (x <- HttpClient$new(url = "https://hb.opencpu.org",
#'   hooks = list(response = fun_resp)))
#' x$url
#' x$hooks
#' r1 <- x$get('get')
#'
#' # both
#' (x <- HttpClient$new(url = "https://hb.opencpu.org",
#'   hooks = list(request = fun_req, response = fun_resp)))
#' x$get("get")
#' }
NULL
