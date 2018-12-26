context("HttpClient: verb")

test_that("verb: works", {
  skip_on_cran()

  x <- HttpClient$new(url = hb())

  expect_is(x$verb, "function")
  expect_named(formals(x$verb), c("verb", "..."))

  aa <- x$verb('get')

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())
})

test_that("verb: works for all supported verbs + retry", {
  skip_on_cran()

  x <- HttpClient$new(url = hb())

  expect_is(x$verb('get', path = "get"), "HttpResponse")
  expect_is(x$verb('post', path = "post"), "HttpResponse")
  expect_is(x$verb('put', path = "put"), "HttpResponse")
  expect_is(x$verb('patch', path = "patch"), "HttpResponse")
  expect_is(x$verb('delete', path = "delete"), "HttpResponse")
  expect_is(x$verb('head'), "HttpResponse")
  expect_is(x$verb('retry', 'get', path = "status/400"), "HttpResponse")
})

test_that("verb: fails well", {
  skip_on_cran()

  x <- HttpClient$new(url = hb())

  # fails when non-character verb value passed
  expect_error(x$verb(5), "is.character\\(verb\\) is not TRUE")

  # fails when verb=retry, but no method passed to retry
  expect_error(x$verb('retry'), "argument \"verb\" is missing")

  # to prevent an endless loop if user supplies verb to the verb 
  # method, don't allow 'verb' to be passed to $verb()
  expect_error(x$verb('verb'), "'verb' must be one of")
  # fails correctly when unsupported verb passed
  expect_error(x$verb("foo"), "'verb' must be one of")
})
