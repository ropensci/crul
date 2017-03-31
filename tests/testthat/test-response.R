context("HttpResponse")

test_that("HttpResponse works", {
  expect_is(HttpResponse, "R6ClassGenerator")

  aa <- HttpResponse$new(
    method = "get",
    url = "https://httpbin.org",
    status_code = 201,
    request_headers = list(useragent = "foo bar"),
    content = charToRaw("hello world"),
    request = list()
  )

  expect_is(aa, "HttpResponse")
  expect_null(aa$handle)
  expect_null(aa$opts)
  expect_is(aa$url, "character")
  expect_is(aa$method, "character")
  expect_is(aa$content, "raw")
  expect_null(aa$modified)
  expect_is(aa$parse, "function")
  expect_is(aa$raise_for_status, "function")
  expect_is(aa$request_headers, "list")
  expect_null(aa$response_headers)
  expect_equal(aa$status_code, 201)
  expect_is(aa$status_http, "function")
  expect_is(aa$success, "function")
  expect_true(aa$success())
  expect_null(aa$times)
  expect_is(aa$request, "list")
})

test_that("HttpResponse fails well", {
  expect_error(HttpResponse$new(), "argument \"url\" is missing")
})
