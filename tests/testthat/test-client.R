context("HttpClient")

test_that("HttpClient works", {
  skip_on_cran()

  expect_is(HttpClient, "R6ClassGenerator")

  aa <- HttpClient$new(url = "https://httpbin.org")

  expect_is(aa, "HttpClient")
  expect_null(aa$handle)
  expect_null(aa$opts)
  expect_is(aa$url, "character")
  expect_is(aa$make_request, "function")
  expect_is(aa$post, "function")
  expect_is(aa$get, "function")
})

test_that("HttpClient fails well", {
  skip_on_cran()

  expect_error(HttpClient$new(), "need one of url or handle")
})
