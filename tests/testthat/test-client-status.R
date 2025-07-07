skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("HTTP status is as expected", {
  cli <- HttpClient$new(url = hb())

  # im a teapot
  aa <- cli$get("status/418")
  expect_s3_class(aa, "HttpResponse")
  expect_type(aa$content, "raw")
  expect_equal(aa$method, "get")
  expect_equal(aa$status_code, 418)
  expect_match(aa$response_headers[[1]], "418")

  # method not allowed
  bb <- cli$get("status/405")
  expect_s3_class(bb, "HttpResponse")
  expect_type(bb$content, "raw")
  expect_equal(bb$method, "get")
  expect_equal(bb$status_code, 405)
  expect_match(bb$response_headers[[1]], "405")

  # service unavailable
  cc <- cli$get("status/503")
  expect_s3_class(cc, "HttpResponse")
  expect_type(cc$content, "raw")
  expect_equal(cc$method, "get")
  expect_equal(cc$status_code, 503)
  expect_match(cc$response_headers[[1]], "503")

  # Partial Content
  dd <- cli$get("status/206")
  expect_s3_class(dd, "HttpResponse")
  expect_type(dd$content, "raw")
  expect_equal(dd$method, "get")
  expect_equal(dd$status_code, 206)
  expect_match(dd$response_headers[[1]], "206")
})
