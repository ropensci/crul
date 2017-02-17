context("AsyncVaried")

test_that("AsyncVaried works", {
  skip_on_cran()

  expect_is(AsyncVaried, "R6ClassGenerator")

  req1 <- HttpRequest$new(url = "https://httpbin.org/get")$get()
  req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post()

  aa <- AsyncVaried$new(req1, req2)

  expect_is(aa, "AsyncVaried")
  expect_is(aa$.__enclos_env__$private$async_request, "function")
  expect_is(aa$parse, "function")
  expect_is(aa$content, "function")
  expect_is(aa$requests, "function")

  # before requests
  expect_equal(length(aa$content()), 0)
  expect_equal(length(aa$status()), 0)
  expect_equal(length(aa$status_code()), 0)
  expect_equal(length(aa$times()), 0)

  # after requests
  aa$request()
  expect_equal(length(aa$content()), 2)
  expect_equal(length(aa$status()), 2)
  expect_equal(length(aa$status_code()), 2)
  expect_equal(length(aa$times()), 2)
})

test_that("AsyncVaried fails well", {
  skip_on_cran()

  expect_error(AsyncVaried$new(), "must pass in at least one request")
  expect_error(AsyncVaried$new(5), "all inputs must be of class 'HttpRequest'")
})
