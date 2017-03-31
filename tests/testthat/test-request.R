context("HttpRequest")

test_that("HttpRequest works", {
  expect_is(HttpRequest, "R6ClassGenerator")

  aa <- HttpRequest$new(url = "https://httpbin.org")

  expect_is(aa, "HttpRequest")
  expect_null(aa$handle)
  expect_length(aa$opts, 0)
  expect_is(aa$url, "character")
  expect_is(aa$headers, "list")
  expect_is(aa$post, "function")
  expect_is(aa$get, "function")

  expect_is(aa$print, "function")
  expect_output(aa$print(), "<crul http request> ")
})

test_that("HttpRequest - get", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$get()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "get")
  expect_equal(aa$url, "https://httpbin.org")
})

test_that("HttpRequest - post", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$post()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "post")
  expect_equal(aa$url, "https://httpbin.org")
})

test_that("HttpRequest - put", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$put()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "put")
  expect_equal(aa$url, "https://httpbin.org")
})

test_that("HttpRequest - patch", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$patch()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "patch")
  expect_equal(aa$url, "https://httpbin.org")
})

test_that("HttpRequest - delete", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$delete()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "delete")
  expect_equal(aa$url, "https://httpbin.org")
})

test_that("HttpRequest - head", {
  aa <- HttpRequest$new(url = "https://httpbin.org")$head()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "head")
  expect_equal(aa$url, "https://httpbin.org")
})


test_that("HttpRequest fails well", {
  expect_error(HttpRequest$new(), "need one of url or handle")
})
