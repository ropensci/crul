context("HttpStubbedResponse")

test_that("HttpStubbedResponse works", {
  skip_on_cran()

  expect_is(HttpStubbedResponse, "R6ClassGenerator")

  x <- HttpStubbedResponse$new(method = "get", url = "https://httpbin.org")

  expect_is(x, "HttpStubbedResponse")
  expect_is(x$parse, "function")
  expect_is(x$success, "function")
  expect_is(x$status_http, "function")
  expect_is(x$raise_for_status, "function")
})
