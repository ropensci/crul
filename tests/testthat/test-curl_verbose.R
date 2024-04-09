skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("curl_verbose", {
  # is a function
  expect_is(curl_verbose, "function")
  
  # & returns a function
  expect_is(curl_verbose(), "function")

  # params
  expect_named(formals(curl_verbose),
    c("data_out", "data_in", "info", "ssl"))
  expect_named(formals(curl_verbose()), c("type", "msg"))

  # used in a request
  ## FIXME: not sure how to do this
})
