context("HttpRequest")

test_that("HttpRequest works", {
  expect_is(HttpRequest, "R6ClassGenerator")

  aa <- HttpRequest$new(url = "http://localhost:80")

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
  aa <- HttpRequest$new(url = "http://localhost:80")$get()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "get")
  expect_equal(aa$url, "http://localhost:80")
})

test_that("HttpRequest - post", {
  aa <- HttpRequest$new(url = "http://localhost:80")$post()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "post")
  expect_equal(aa$url, "http://localhost:80")
})

test_that("HttpRequest - put", {
  aa <- HttpRequest$new(url = "http://localhost:80")$put()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "put")
  expect_equal(aa$url, "http://localhost:80")
})

test_that("HttpRequest - patch", {
  aa <- HttpRequest$new(url = "http://localhost:80")$patch()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "patch")
  expect_equal(aa$url, "http://localhost:80")
})

test_that("HttpRequest - delete", {
  aa <- HttpRequest$new(url = "http://localhost:80")$delete()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "delete")
  expect_equal(aa$url, "http://localhost:80")
})

test_that("HttpRequest - head", {
  aa <- HttpRequest$new(url = "http://localhost:80")$head()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "head")
  expect_equal(aa$url, "http://localhost:80")
})


test_that("HttpRequest fails well", {
  expect_error(HttpRequest$new(), "need one of url or handle")
})
