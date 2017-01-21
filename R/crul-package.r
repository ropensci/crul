#' \strong{HTTP R client}
#'
#' @section Package API:
#' \itemize{
#'  \item \code{\link{HttpClient}} - create a connection client, set all
#'  your http options, make http requests
#'  \item \code{\link{HttpResponse}} - mostly for internal use, handles
#'  http responses
#' }
#'
#' @section HTTP conditions:
#' We use \code{fauxpas} if you have it installed for handling HTTP
#' conditions but if it's not installed we use \pkg{httpcode}
#'
#' @import curl
#' @importFrom R6 R6Class
#' @name crul-package
#' @aliases crul
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @docType package
NULL
