context("user-agent")

test_that("user-agent", {
  skip_on_cran()

  aa <- make_ua()

  expect_is(aa, "character")
  expect_match(aa, 'libcurl')
  expect_match(aa, 'r-curl')
  expect_match(aa, 'crul')
})
