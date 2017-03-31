context("handle")

test_that("handle - works", {
  aa <- handle("https://httpbin.org")

  expect_is(aa, "list")
  expect_is(aa$url, "character")
  expect_is(aa$handle, "curl_handle")
  expect_match(aa$url, "https")
})

test_that("handle fails well", {
  expect_error(handle(), "argument \"url\" is missing")
})
