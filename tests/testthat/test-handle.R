context("handle")

test_that("handle - works", {
  skip_on_cran()

  aa <- handle(hb())

  expect_is(aa, "list")
  expect_is(aa$url, "character")
  expect_is(aa$handle, "curl_handle")
  expect_match(aa$url, "https")
})

test_that("handle fails well", {
  skip_on_cran()
  
  expect_error(handle(), "argument \"url\" is missing")
})
