context("Async")

test_that("Async works", {
  skip_on_cran()

  expect_is(Async, "R6ClassGenerator")

  aa <- Async$new(urls = 'https://httpbin.org/get')

  expect_is(aa, "Async")
  expect_null(aa$handle)
  expect_is(aa$urls, "character")
  expect_is(aa$.__enclos_env__$private$async_request, "function")
  expect_null(aa$post)
  expect_is(aa$get, "function")
})

test_that("Async fails well", {
  skip_on_cran()

  expect_error(Async$new(), "\"urls\" is missing, with no default")
})
