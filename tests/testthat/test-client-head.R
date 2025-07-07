skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("head request works", {
  cli <- HttpClient$new(url = "https://www.google.com")
  aa <- cli$head()

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "head")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  # content is empty
  expect_equal(aa$content, raw(0))
})


test_that("head - query passed to head doesn't fail", {
  cli <- HttpClient$new(url = "https://www.google.com")
  aa <- cli$head(query = list(foo = "bar"))

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "head")
  expect_type(aa$parse, "closure")
  expect_true(aa$success())
  expect_match(aa$request$url$url, "foo")
  expect_match(aa$request$url$url, "bar")

  # content is empty
  expect_equal(aa$content, raw(0))
})


test_that("with auth works", {
  cli <- HttpClient$new(url = hb(), auth = auth("foo", "bar"))
  aa <- cli$head("/basic-auth/foo/bar")

  expect_s3_class(aa, "HttpResponse")
  expect_equal(aa$method, "head")
  expect_true(aa$success())
  expect_equal(aa$status_code, 200)
  expect_equal(aa$request$options$userpwd, "foo:bar")
})
