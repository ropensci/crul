#' **HTTP R client**
#'
#' @section Package API:
#' \itemize{
#'  \item [HttpClient()] - create a connection client, set all
#'  your http options, make http requests
#'  \item [HttpResponse()] - mostly for internal use, handles
#'  http responses
#'  \item [Paginator()] - auto-paginate through requests
#'  \item [Async()] - asynchronous requests
#'  \item [AsyncVaried()] - varied asynchronous requests
#'  \item [HttpRequest()] - generate an HTTP request, mostly for
#'  use in building requests to be used in `Async` or `AsyncVaried`
#'  \item [mock()] - Turn on/off mocking, via `webmockr`
#'  \item [auth()] - Simple authentication helper
#'  \item [proxy()] - Proxy helper
#' }
#'
#' @section HTTP conditions:
#' We use `fauxpas` if you have it installed for handling HTTP
#' conditions but if it's not installed we use \pkg{httpcode}
#'
#' @section Mocking:
#' Mocking HTTP requests is supported via the \pkg{webmockr}
#' package. See [mock] for guidance.
#'
#' @importFrom curl curl_escape curl_fetch_disk curl_fetch_memory
#' curl_fetch_stream curl_options curl_version handle_reset handle_setform
#' handle_setheaders handle_setopt multi_add multi_cancel multi_list
#' multi_run new_handle new_pool parse_headers
#' @importFrom R6 R6Class
#' @name crul-package
#' @aliases crul
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @docType package
NULL
