skip_on_cran()
skip_if_offline(url_parse(hb())$domain)


test_that("handle - works", {
  aa <- handle(hb())

  expect_type(aa, "list")
  expect_type(aa$url, "character")
  expect_s3_class(aa$handle, "curl_handle")
  expect_match(aa$url, "https")
})

test_that("handle fails well", {
  expect_error(handle(), "argument \"url\" is missing")
})
