skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

context("HttpClient: patch")

test_that("patch request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$patch("patch")

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "patch")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("patch request with body", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$patch("patch", body = list(hello = "world"))

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "patch")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})
