skip_on_cran()
skip_if_offline(url_parse(hb())$domain)


test_that("ok works with character input", {
  expect_type(ok, "closure")

  # good
  expect_true(ok(hb()))

  # bad
  expect_message(z <- ok('http://foo.bar'))
  expect_false(z)
})


test_that("ok works with HttpClient input", {
  # good
  z <- crul::HttpClient$new(hb("/status/200"))
  expect_true(ok(z))

  # bad
  z <- crul::HttpClient$new(hb("/status/404"))
  expect_false(ok(z))
})


test_that("ok works multiple status codes", {
  z <- crul::HttpClient$new(hb("/status/200"))
  expect_true(ok(z, c(200L, 201L)))
  expect_error(ok(z, c(200L, 901L)))
})


test_that("ok random user agents", {
  ua_val <- NULL
  fxn <- function(request) {
    ua <- request$options$useragent
    ua_val <<- ua
    message(paste0("User-agent: ", ua), sep = "\n")
  }
  z <- crul::HttpClient$new(hb(), hooks = list(request = fxn))
  expect_message(ok(z, ua_random = TRUE), 'User-agent:')
  # us string is one of the strings in agents
  expect_true(ua_val %in% crul:::agents)
  # agents is length 50  and character
  expect_type(crul:::agents, "character")
  expect_equal(length(crul:::agents), 50)
})


test_that("ok fails well", {
  expect_error(ok(5), "no 'ok' method for numeric")
  expect_error(ok(mtcars), "no 'ok' method for data.frame")
  expect_error(ok(list()), "no 'ok' method for list")
  expect_error(ok(), "argument \"x\" is missing")
  expect_error(ok(hb("/status/404"), status = 567L), "not in acceptable set")
  # ua_random must be logical
  expect_error(ok(hb("/status/404"), ua_random = "adf"))
})
