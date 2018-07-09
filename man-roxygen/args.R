#' @param url (character) A url. One of \code{url} or \code{handle} required.
#' @param opts (list) curl options, a named list. See
#' \code{\link[curl]{curl_options}} for available curl options
#' @param proxies an object of class \code{proxy}, as returned from the
#' \code{\link{proxy}} function. Supports one proxy for now
#' @param auth result of a call to the \code{\link{auth}} function, 
#' e.g. \code{auth(user = "foo", pwd = "bar")}
#' @param headers (list) a named list of headers
#' @param handle A handle, see \code{\link{handle}}
#' @param progress a function with logic for printing a progress
#' bar for an HTTP request, ultimiately passed down to \pkg{curl}.
#' only supports httr::progress() for now
