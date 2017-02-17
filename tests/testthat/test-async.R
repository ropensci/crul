context("Async")

test_that("Async works", {
  skip_on_cran()

  expect_is(Async, "R6ClassGenerator")

  aa <- Async$new(urls = c('https://httpbin.org/get', 'https://google.com'))

  expect_is(aa, "Async")
  expect_null(aa$handle)
  expect_is(aa$urls, "character")
  expect_equal(length(aa$urls), 2)
  expect_is(aa$.__enclos_env__$private$gen_interface, "function")

  expect_is(aa$get, "function")
  expect_is(aa$post, "function")
  expect_is(aa$put, "function")
  expect_is(aa$patch, "function")
  expect_is(aa$delete, "function")
  expect_is(aa$head, "function")

  # after calling
  res <- aa$get()
  expect_is(res, "list")
  expect_equal(length(res), 2)
  expect_is(res[[1]], "HttpResponse")
  expect_is(res[[1]]$request, "HttpRequest")
  expect_is(res[[1]]$content, "raw")
})

test_that("Async fails well", {
  skip_on_cran()

  expect_error(Async$new(), "\"urls\" is missing, with no default")
})
