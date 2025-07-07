skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("verb: works", {
  x <- HttpClient$new(url = hb())

  expect_type(x$verb, "closure")
  expect_named(formals(x$verb), c("verb", "..."))

  aa <- x$verb('get')

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())
})

test_that("verb: works for all supported verbs + retry", {
  x <- HttpClient$new(url = hb())

  expect_s3_class(x$verb('get', path = "get"), "HttpResponse")
  expect_s3_class(x$verb('post', path = "post"), "HttpResponse")
  expect_s3_class(x$verb('put', path = "put"), "HttpResponse")
  expect_s3_class(x$verb('patch', path = "patch"), "HttpResponse")
  expect_s3_class(x$verb('delete', path = "delete"), "HttpResponse")
  expect_s3_class(x$verb('head'), "HttpResponse")
  expect_s3_class(x$verb('retry', 'get', path = "status/400"), "HttpResponse")
})

test_that("verb: fails well", {
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

test_that("verb: with auth works", {
  cli <- HttpClient$new(url = hb(), auth = auth("foo", "bar"))
  aa <- cli$verb("get", "/basic-auth/foo/bar")

  expect_s3_class(aa, "HttpResponse")
  expect_equal(aa$method, "get")
  expect_true(aa$success())
  expect_equal(aa$status_code, 200)
  expect_equal(aa$request$options$userpwd, "foo:bar")
})
