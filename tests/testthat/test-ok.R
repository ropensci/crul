context("ok: character")
test_that("ok works with character input", {
  skip_on_cran()

  expect_is(ok, "function")

  # good
  expect_true(ok(base_url))

  # bad
  expect_message(z <- ok('http://foo.bar'))
  expect_false(z)
})


context("ok: HttpClient")
test_that("ok works with HttpClient input", {
  skip_on_cran()

  # good
  z <- crul::HttpClient$new(hb("/status/200"))
  expect_true(ok(z))
  
  # bad
  z <- crul::HttpClient$new(hb("/status/404"))
  expect_false(ok(z))
})


context("ok: fails well")
test_that("ok fails well", {
  skip_on_cran()

  expect_error(ok(5), "no 'ok' method for numeric")
  expect_error(ok(mtcars), "no 'ok' method for data.frame")
  expect_error(ok(list()), "no 'ok' method for list")
  expect_error(ok(), "argument \"x\" is missing")
})
