skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("delete request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$delete("delete")

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "delete")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("delete request with body", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$delete("delete", body = list(hello = "world"))

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "delete")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse("UTF-8"), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})
