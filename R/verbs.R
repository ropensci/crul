#' HTTP verb info: GET
#' 
#' The GET method requests a representation of the specified resource. 
#' Requests using GET should only retrieve data.
#' 
#' @section The GET method:
#' The GET method requests transfer of a current selected 
#' representation for the target resource.  GET is the primary 
#' mechanism of information retrieval and the focus of almost all 
#' performance optimizations. Hence, when people speak of retrieving 
#' some identifiable information via HTTP, they are generally referring 
#' to making a GET request.
#' 
#' It is tempting to think of resource identifiers as remote file system
#' pathnames and of representations as being a copy of the contents of
#' such files.  In fact, that is how many resources are implemented (see
#' Section 9.1 (<https://tools.ietf.org/html/rfc7231#section-9.1>) 
#' for related security considerations).  However, there are
#' no such limitations in practice.  The HTTP interface for a resource
#' is just as likely to be implemented as a tree of content objects, a
#' programmatic view on various database records, or a gateway to other 
#' information systems.  Even when the URI mapping mechanism is tied to
#' a file system, an origin server might be configured to execute the
#' files with the request as input and send the output as the
#' representation rather than transfer the files directly.  Regardless,
#' only the origin server needs to know how each of its resource identifiers
#' corresponds to an implementation and how each implementation manages 
#' to select and send a current representation of the target resource 
#' in a response to GET.
#' 
#' A client can alter the semantics of GET to be a "range request",
#' requesting transfer of only some part(s) of the selected
#' representation, by sending a Range header field in the request
#' (RFC7233: <https://tools.ietf.org/html/rfc7233>).
#' 
#' A payload within a GET request message has no defined semantics;
#' sending a payload body on a GET request might cause some existing
#' implementations to reject the request.
#' 
#' The response to a GET request is cacheable; a cache MAY use it to
#' satisfy subsequent GET and HEAD requests unless otherwise indicated
#' by the Cache-Control header field (Section 5.2 of RFC7234:
#' <https://tools.ietf.org/html/rfc7234#section-5.2>).
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$get(path = 'get')
#' }
#'
#' @name verb-GET
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc7231#section-4.3.1>
NULL

#' HTTP verb info: POST
#' 
#' The POST method is used to submit an entity to the specified resource, 
#' often causing a change in state or side effects on the server.
#' 
#' @section The POST method:
#' If one or more resources has been created on the origin server as a
#' result of successfully processing a POST request, the origin server
#' SHOULD send a 201 (Created) response containing a Location header
#' field that provides an identifier for the primary resource created
#' (Section 7.1.2 <https://tools.ietf.org/html/rfc7231#section-7.1.2>) 
#' and a representation that describes the status of the
#' request while referring to the new resource(s).
#'  
#' See <https://tools.ietf.org/html/rfc7231#section-4.3.3> for further
#' details.
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' 
#' # a named list
#' x$post(path='post', body = list(hello = "world"))
#' 
#' # a string
#' x$post(path='post', body = "hello world")
#'
#' # an empty body request
#' x$post(path='post')
#' 
#' # encode="form"
#' res <- x$post(path="post",
#'   encode = "form",
#'   body = list(
#'     custname = 'Jane',
#'     custtel = '444-4444',
#'     size = 'small',
#'     topping = 'bacon',
#'     comments = 'make it snappy'
#'   )
#' )
#' jsonlite::fromJSON(res$parse("UTF-8"))
#' 
#' # encode="json"
#' res <- x$post("post",
#'   encode = "json",
#'   body = list(
#'     genus = 'Gagea',
#'     species = 'pratensis'
#'   )
#' )
#' jsonlite::fromJSON(res$parse())
#' }
#'
#' @name verb-POST
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc7231#section-4.3.3>
NULL

#' HTTP verb info: PUT
#' 
#' The PUT method replaces all current representations of the target 
#' resource with the request payload.
#' 
#' @section The PUT method:
#' The PUT method requests that the state of the target resource be
#' created or replaced with the state defined by the representation
#' enclosed in the request message payload.  A successful PUT of a given
#' representation would suggest that a subsequent GET on that same
#' target resource will result in an equivalent representation being
#' sent in a 200 (OK) response. However, there is no guarantee that
#' such a state change will be observable, since the target resource
#' might be acted upon by other user agents in parallel, or might be
#' subject to dynamic processing by the origin server, before any
#' subsequent GET is received.  A successful response only implies that
#' the user agent's intent was achieved at the time of its processing by
#' the origin server.
#' 
#' If the target resource does not have a current representation and the
#' PUT successfully creates one, then the origin server MUST inform the
#' user agent by sending a 201 (Created) response.  If the target
#' resource does have a current representation and that representation
#' is successfully modified in accordance with the state of the enclosed
#' representation, then the origin server MUST send either a 200 (OK) or
#' a 204 (No Content) response to indicate successful completion of the
#' request.
#'  
#' See <https://tools.ietf.org/html/rfc7231#section-4.3.4> for further
#' details.
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$put(path = 'put', body = list(foo = "bar"))
#' }
#'
#' @name verb-PUT
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc7231#section-4.3.4>
NULL

#' HTTP verb info: PATCH
#' 
#' The PATCH method is used to apply partial modifications to a resource.
#' 
#' @section The PATCH method:
#' The PATCH method requests that a set of changes described in the
#' request entity be applied to the resource identified by the Request-
#' URI.  The set of changes is represented in a format called a "patch
#' document" identified by a media type.  If the Request-URI does not
#' point to an existing resource, the server MAY create a new resource,
#' depending on the patch document type (whether it can logically modify
#' a null resource) and permissions, etc.
#'  
#' See <https://tools.ietf.org/html/rfc5789#section-2> for further
#' details.
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$patch(path = 'patch', body = list(hello = "mars"))
#' }
#'
#' @name verb-PATCH
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc5789>
NULL

#' HTTP verb info: DELETE
#' 
#' The DELETE method deletes the specified resource.
#' 
#' @section The DELETE method:
#' The DELETE method requests that the origin server remove the
#' association between the target resource and its current
#' functionality.  In effect, this method is similar to the rm command
#' in UNIX: it expresses a deletion operation on the URI mapping of the
#' origin server rather than an expectation that the previously
#' associated information be deleted.
#'  
#' See <https://tools.ietf.org/html/rfc7231#section-4.3.5> for further
#' details.
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$delete(path = 'delete')
#' 
#' ## a list
#' (res1 <- x$delete('delete', body = list(hello = "world"), verbose = TRUE))
#' jsonlite::fromJSON(res1$parse("UTF-8"))
#'
#' ## a string
#' (res2 <- x$delete('delete', body = "hello world", verbose = TRUE))
#' jsonlite::fromJSON(res2$parse("UTF-8"))
#'
#' ## empty body request
#' x$delete('delete', verbose = TRUE)
#' }
#'
#' @name verb-DELETE
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc7231#section-4.3.5>
NULL

#' HTTP verb info: HEAD
#' 
#' The HEAD method asks for a response identical to that of a GET request, 
#' but without the response body.
#' 
#' @section The HEAD method:
#' The HEAD method is identical to GET except that the 
#' server MUST NOT send a message body in the response (i.e., the 
#' response terminates at the end of the header section).  The server 
#' SHOULD send the same header fields in response to a HEAD request as 
#' it would have sent if the request had been a GET, except that the 
#' payload header fields MAY be omitted.  This method can 
#' be used for obtaining metadata about the selected representation 
#' without transferring the representation data and is often used for 
#' testing hypertext links for validity, accessibility, and recent 
#' modification.
#' 
#' See <https://tools.ietf.org/html/rfc7231#section-4.3.2> for further
#' details.
#' 
#' @examples \dontrun{
#' x <- HttpClient$new(url = "https://httpbin.org")
#' x$head()
#' }
#'
#' @name verb-HEAD
#' @family verbs
#' @seealso [crul-package]
#' @references <https://tools.ietf.org/html/rfc7231#section-4.3.2>
NULL
