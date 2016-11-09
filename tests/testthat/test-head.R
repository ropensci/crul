context("request: head")

test_that("head request works", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://www.google.com")
  aa <- cli$head()

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "head")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  # content is empty
  expect_equal(aa$content, raw(0))
})
