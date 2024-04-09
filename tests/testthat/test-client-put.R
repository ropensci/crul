skip_on_cran()
skip_if_offline(url_parse(hb())$domain)
context("HttpClient: put")

test_that("put request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$put("put")

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "put")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("put request with body", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$put("put", body = list(hello = "world"))

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "put")
  expect_is(aa$parse, "function")
  expect_is(aa$parse("UTF-8"), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})
