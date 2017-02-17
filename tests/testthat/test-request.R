context("HttpRequest")

test_that("HttpRequest works", {
  skip_on_cran()

  expect_is(HttpRequest, "R6ClassGenerator")

  aa <- HttpRequest$new(url = "https://httpbin.org")

  expect_is(aa, "HttpRequest")
  expect_null(aa$handle)
  expect_length(aa$opts, 0)
  expect_is(aa$url, "character")
  expect_is(aa$headers, "list")
  expect_is(aa$post, "function")
  expect_is(aa$get, "function")
})

test_that("HttpRequest fails well", {
  skip_on_cran()

  expect_error(HttpRequest$new(), "need one of url or handle")
})
