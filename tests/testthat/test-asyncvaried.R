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

context("AsyncVaried - order of results")
test_that("AsyncVaried - order", {
  skip_on_cran()

  req1 <- HttpRequest$new(url = "https://httpbin.org/get?a=5")$get()
  req2 <- HttpRequest$new(url = "https://httpbin.org/get?b=6")$get()
  req3 <- HttpRequest$new(url = "https://httpbin.org/get?c=7")$get()
  aa <- AsyncVaried$new(req1, req2, req3)
  aa$request()
  out <- aa$responses()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_is(out[[3]], "HttpResponse")

  expect_match(out[[1]]$url, "a=5")
  expect_match(out[[2]]$url, "b=6")
  expect_match(out[[3]]$url, "c=7")
})
