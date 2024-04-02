#' @section Package API:
#' 
#' - [HttpClient()] - create a connection client, set all
#'  your http options, make http requests
#' - [HttpResponse()] - mostly for internal use, handles
#'  http responses
#' - [Paginator()] - auto-paginate through requests
#' - [Async()] - asynchronous requests
#' - [AsyncVaried()] - varied asynchronous requests
#' - [HttpRequest()] - generate an HTTP request, mostly for
#'  use in building requests to be used in `Async` or `AsyncVaried`
#' - [mock()] - Turn on/off mocking, via `webmockr`
#' - [auth()] - Simple authentication helper
#' - [proxy()] - Proxy helper
#' - [upload()] - File upload helper
#' - set curl options globally: [set_auth()], [set_headers()], 
#'   [set_opts()], [set_proxy()], and [crul_settings()]
#' 
#' @section HTTP verbs (or HTTP request methods):
#' 
#' See [verb-GET], [verb-POST], [verb-PUT], [verb-PATCH], [verb-DELETE], 
#' [verb-HEAD] for details.
#'
#' - [HttpClient] is the main interface for making HTTP requests, 
#' and includes methods for each HTTP verb
#' - [HttpRequest] allows you to prepare a HTTP payload for use with
#' [AsyncVaried], which provides asynchronous requests for varied 
#' HTTP methods
#' - [Async] provides asynchronous requests for a single HTTP method
#' at a time
#' - the `verb()` method can be used on all the above to request 
#' a specific HTTP verb
#' 
#' @section Checking HTTP responses:
#' 
#' [HttpResponse()] has helpers for checking and raising warnings/errors.
#' 
#' - [content-types] details the various options for checking content
#' types and throwing a warning or error if the response content
#' type doesn't match what you expect. Mis-matched content-types are
#' typically a good sign of a bad response. There's methods built
#' in for json, xml and html, with the ability to set any
#' custom content type
#' - `raise_for_status()` is a method on [HttpResponse()] that checks
#' the HTTP status code, and errors with the appropriate message for
#' the HTTP status code, optionally using the package `fauxpas`
#' if it's installed.
#'
#' @section HTTP conditions:
#' We use `fauxpas` if you have it installed for handling HTTP
#' conditions but if it's not installed we use \pkg{httpcode}
#'
#' @section Mocking:
#' Mocking HTTP requests is supported via the \pkg{webmockr}
#' package. See [mock] for guidance, and 
#' <https://books.ropensci.org/http-testing/>
#' 
#' @section Caching:
#' Caching HTTP requests is supported via the \pkg{vcr}
#' package. See <https://books.ropensci.org/http-testing/>
#' 
#' @section Links:
#' 
#' Source code: <https://github.com/ropensci/crul>
#' 
#' Bug reports/feature requests: <https://github.com/ropensci/crul/issues>
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom curl curl_escape curl_fetch_disk curl_fetch_memory
#' curl_fetch_stream curl_options curl_version handle_reset handle_setform
#' handle_setheaders handle_setopt multi_add multi_cancel multi_list
#' multi_run new_handle new_pool parse_headers
#' @importFrom R6 R6Class
#' @importFrom httpcode http_code
## usethis namespace: end
NULL
