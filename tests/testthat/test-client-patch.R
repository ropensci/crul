skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("patch request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$patch("patch")

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "patch")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("patch request with body", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$patch("patch", body = list(hello = "world"))

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "patch")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})
