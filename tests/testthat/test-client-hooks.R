skip_on_cran()
skip_if_offline(url_parse(hb())$domain)


test_that("hooks: requests", {
  fun_req <- function(request) {
    cat("Requesting: ", request$url$url, sep = "\n")
  }
  x <- HttpClient$new(url = hb(), hooks = list(request = fun_req))

  expect_type(x$hooks, "list")
  expect_named(x$hooks, "request")
  expect_type(x$hooks$request, "closure")

  expect_output(aa <- x$get("get"), "Requesting")

  # HttpResponse object is still as normal
  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, "curl_handle")
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse("UTF-8"), "character")
  expect_true(aa$success())
})


test_that("hooks: responses", {
  fun_resp <- function(response) {
    cat(paste0("status_code: ", response$status_code), sep = "\n")
  }
  x <- HttpClient$new(url = hb(), hooks = list(response = fun_resp))

  expect_type(x$hooks, "list")
  expect_named(x$hooks, "response")
  expect_type(x$hooks$response, "closure")

  expect_output(aa <- x$get("get"), "status_code")

  # HttpResponse object is still as normal
  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, "curl_handle")
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse("UTF-8"), "character")
  expect_true(aa$success())
})


test_that("hooks: request and response", {
  fun_req <- function(request) {
    cat("Requesting: ", request$url$url, sep = "\n")
  }
  fun_resp <- function(response) {
    cat(paste0("status_code: ", response$status_code), sep = "\n")
  }
  x <- HttpClient$new(
    url = hb(),
    hooks = list(request = fun_req, response = fun_resp)
  )

  expect_type(x$hooks, "list")
  expect_named(x$hooks, c("request", "response"))
  expect_type(x$hooks$request, "closure")
  expect_type(x$hooks$response, "closure")

  expect_output(aa <- x$get("get"), "Requesting")
  expect_output(aa <- x$get("get"), "status_code")

  expect_s3_class(aa, "HttpResponse")
})


test_that("hooks: fails well", {
  # fails when non-list passed
  expect_error(
    HttpClient$new(url = hb(), hooks = 5),
    "hooks must be of class list"
  )

  # must be a named list
  expect_error(
    HttpClient$new(url = hb(), hooks = list("foo")),
    "'hooks' must be a named list"
  )

  # only allows request and response
  expect_error(
    HttpClient$new(url = hb(), hooks = list(foo = "bar")),
    "unsupported names in 'hooks' list: only request, response supported"
  )

  # only functions allowed
  expect_error(
    HttpClient$new(url = hb(), hooks = list(request = "bar")),
    "hooks must be functions"
  )
})
