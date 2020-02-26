context("HttpRequest")

test_that("HttpRequest works", {
  expect_is(HttpRequest, "R6ClassGenerator")

  aa <- HttpRequest$new(url = hb())

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
  aa <- HttpRequest$new(url = hb())$get()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "get")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - post", {
  aa <- HttpRequest$new(url = hb())$post()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "post")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - put", {
  aa <- HttpRequest$new(url = hb())$put()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "put")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - patch", {
  aa <- HttpRequest$new(url = hb())$patch()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "patch")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - delete", {
  aa <- HttpRequest$new(url = hb())$delete()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "delete")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - head", {
  aa <- HttpRequest$new(url = hb())$head()

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "head")
  expect_equal(aa$url, hb())
})

test_that("HttpRequest - verb", {
  aa <- HttpRequest$new(url = hb())$verb('get')

  expect_is(aa, "HttpRequest")
  expect_equal(aa$method(), "get")
  expect_equal(aa$url, hb())

  bb <- HttpRequest$new(url = hb())$verb('post')
  expect_equal(bb$method(), "post")

  # fails well
  expect_error(HttpRequest$new(url = hb())$verb(), "missing")
  expect_error(HttpRequest$new(url = hb())$verb('verb'), "must be one of")
  expect_error(HttpRequest$new(url = hb())$verb(5), "is not TRUE")
})

test_that("HttpRequest - prints new url after being modified", {
  # query modifies url
  aa <- HttpRequest$new(url = hb())
  bb <- aa$get(query = list(foo = "bar", a = 5))
  expect_output(print(aa), hb())
  expect_output(print(bb), paste0(hb(), "\\?foo=bar&a=5"))

  # handle passed in instead of a url
  aa <- HttpRequest$new(handle = handle(file.path(hb(), "foobar")))
  expect_output(print(aa), file.path(hb(), "foobar"))

  # handle + query
  aa <- HttpRequest$new(handle = handle(hb()))
  bb <- aa$get(query = list(foo = "bar", a = 5))
  expect_output(print(aa), hb())
  expect_output(print(bb), paste0(hb(), "\\?foo=bar&a=5"))
})

test_that("HttpRequest fails well", {
  expect_error(HttpRequest$new(), "need one of url or handle")
})
