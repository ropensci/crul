#' @title Cookie Jar
#' @description Create a CookieJar class
#'
#' @export
#' @family async
#' @template args
#' @param path URL path, appended to the base URL
#' @param ... curl options, only those in the acceptable set from
#' [curl::curl_options()] except the following: httpget, httppost, post,
#' postfields, postfieldsize, and customrequest
#' @details xxxx
#' @examples \dontrun{
#' x <- CookieJar$new()
#' x
#' x$set(name='tasty_cookie', value='yum', domain='httpbin.org', path='/cookies')
#' x$set('gross_cookie', 'blech', domain='httpbin.org', path='/elsewhere')
#' x
#' x$get(name='tasty_cookie')
#' x$get(name='gross_cookie')
#' x$get(name='a_cookie')
#' x$keys()
#' 
#' ck <- CookieJar$new()
#' ck$set(name='tasty_cookie', value='yum', domain='httpbin.org', path='/cookies')
#' con <- HttpClient$new("https://httpbin.org", cookies = ck)
#' res <- con$get("get")
#' res$response_headers
#' }
CookieJar <- R6::R6Class(
  'CookieJar',
  public = list(
    #' @field jar (character) jar to keep cookies in
    jar = list(),

    #' @description print method for `CookieJar` objects
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat("<crul cookie jar> ", sep = "\n")
      cat(" cookies: ", sep = "\n")
      for (i in seq_along(self$jar)) {
        cat(paste0("     ", self$jar[[i]]$name), sep = "\n")
      }
      invisible(self)
    },

    #' @description Create a new `CookieJar` object
    #' @param urls (character) one or more URLs
    #' @return A new `CookieJar` object
    # initialize = function() {
    #   if (!missing(url)) self$url <- url
    # },

    #' @description Define a GET request
    get = function(name, default=NULL, domain=NULL, path=NULL, ...) {
      if (!length(self$jar)) return(NULL)
      bools <- private$cookie_names() == name
      if (!any(bools)) return(NULL)
      self$jar[bools][[1]]
      # try:
      #     return self._find_no_duplicates(name, domain, path)
      # except KeyError:
      #     return default
    },

    #' @description Set 
    set = function(name, value, ...) {
      ck <- self$create_cookie(name, value, ...)
      ck <- self$fix_cookie(ck)
      self$jar <- append(self$jar, list(ck))
      return(ck)
    },

    #' @description Get names for cookies 
    keys = function() private$cookie_names(),

    create_cookie = function(name, value, ...) {
      res <- list('version' = 0,
        'name' = name,
        'value' = value,
        'port' = NULL,
        'domain' = '',
        'path' = '/',
        'secure' = FALSE,
        'expires' = NULL,
        'discard' = TRUE,
        'comment' = NULL,
        'comment_url' = NULL,
        'rest' = list('HttpOnly' = NULL),
        'rfc2109' = FALSE
      )
      badargs <- not_in(list(...), res)
      if (length(badargs)) {
        err <- 'create_cookie() got unexpected keyword arguments: %s'
        stop(sprintf(err, paste0(badargs, collapse=",")))
      }
      res <- modifyList(res, list(...))
      # res['port_specified'] <- as.logical(res[['port']]) %||% NULL
      # res['domain_specified'] <- as.logical(res[['domain']]) %||% NULL
      # res['domain_initial_dot'] = res[['domain']].startswith('.')
      # res['path_specified'] <- as.logical(res[['path']]) %||% NULL
      return(res)
    },

    fix_cookie = function(w) {
      if (grepl('^\"', w$value) && grepl('\"$', w$value))
        w$value <- gsub('\\"', '', w$value)
      return(w)
    }
  ),

  private = list(
    cookie_names = function() vapply(self$jar, "[[", "", "name")  
  )
)

not_in <- function(x, y) {
  names(x)[!names(x) %in% names(y)]
}
