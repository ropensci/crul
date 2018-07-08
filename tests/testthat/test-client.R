context("HttpClient")
test_that("HttpClient works", {
  skip_on_cran()

  expect_is(HttpClient, "R6ClassGenerator")

  aa <- HttpClient$new(url = hb())

  expect_is(aa, "HttpClient")
  expect_null(aa$handle)
  expect_length(aa$opts, 0)
  expect_is(aa$url, "character")
  expect_is(aa$.__enclos_env__$private$make_request, "function")
  expect_is(aa$post, "function")
  expect_is(aa$get, "function")
})

test_that("HttpClient fails well", {
  skip_on_cran()

  expect_error(HttpClient$new(), "need one of url or handle")
})


context("HttpClient - disk")
test_that("HttpClient works", {
  skip_on_cran()

  aa <- HttpClient$new(url = hb())
  f <- tempfile()
  res <- aa$get("get", disk = f)
  lns <- readLines(res$content, n = 10)

  expect_is(aa, "HttpClient")
  expect_is(res$content, "character")
  expect_gt(length(lns), 0)

  unlink(f)
})

test_that("HttpClient disk fails well", {
  skip_on_cran()

  aa <- HttpClient$new(url = hb())
  expect_error(aa$get("get", disk = 5), "invalid 'path' argument")
})


context("HttpClient - stream")
test_that("HttpClient works", {
  skip_on_cran()

  aa <- HttpClient$new(url = hb())
  expect_output(
    res <- aa$get('stream/50', stream = function(x) cat(rawToChar(x))),
    "headers"
  )

  expect_is(res, "HttpResponse")
  expect_null(res$content)
})

test_that("HttpClient disk fails well", {
  skip_on_cran()

  aa <- HttpClient$new(url = hb())
  expect_error(aa$get("get", stream = 5), "could not find function \"fun\"")
})
