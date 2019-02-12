context("HttpClient: request hooks")
test_that("hooks: requests", {
  skip_on_cran()

  fun_req <- function(request) {
    cat("Requesting: ", request$url$url, sep = "\n")
  }
  x <- HttpClient$new(url = "https://httpbin.org",
    hooks = list(request = fun_req))

  expect_is(x$hooks, "list")
  expect_named(x$hooks, "request")
  expect_is(x$hooks$request, "function")

  expect_output(aa <- x$get("get"), "Requesting")

  # HttpResponse object is still as normal
  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, "curl_handle")
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(aa$parse("UTF-8"), "character")
  expect_true(aa$success())
})

context("HttpClient: response hooks")
test_that("hooks: responses", {
  skip_on_cran()

  fun_resp <- function(response) {
    cat(paste0("status_code: ", response$status_code), sep = "\n")
  }
  x <- HttpClient$new(url = "https://httpbin.org",
    hooks = list(response = fun_resp))

  expect_is(x$hooks, "list")
  expect_named(x$hooks, "response")
  expect_is(x$hooks$response, "function")

  expect_output(aa <- x$get("get"), "status_code")

  # HttpResponse object is still as normal
  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, "curl_handle")
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(aa$parse("UTF-8"), "character")
  expect_true(aa$success())
})


context("HttpClient: request and response hook")
test_that("hooks: request and response", {
  skip_on_cran()

  fun_req <- function(request) {
    cat("Requesting: ", request$url$url, sep = "\n")
  }
  fun_resp <- function(response) {
    cat(paste0("status_code: ", response$status_code), sep = "\n")
  }
  x <- HttpClient$new(url = "https://httpbin.org",
    hooks = list(request = fun_req, response = fun_resp))

  expect_is(x$hooks, "list")
  expect_named(x$hooks, c("request", "response"))
  expect_is(x$hooks$request, "function")
  expect_is(x$hooks$response, "function")

  expect_output(aa <- x$get("get"), "Requesting")
  expect_output(aa <- x$get("get"), "status_code")

  expect_is(aa, "HttpResponse")
})


test_that("hooks: fails well", {
  skip_on_cran()

  # fails when non-list passed
  expect_error(HttpClient$new(url = hb(), hooks = 5),
    "hooks must be of class list")

  # must be a named list
  expect_error(HttpClient$new(url = hb(), hooks = list("foo")),
    "'hooks' must be a named list")

  # only allows request and response
  expect_error(HttpClient$new(url = hb(), hooks = list(foo = "bar")),
    "unsupported names in 'hooks' list: only request, response supported")

  # only functions allowed
  expect_error(HttpClient$new(url = hb(), hooks = list(request = "bar")),
    "hooks must be functions")
})
