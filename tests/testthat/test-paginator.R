context("Paginator")

cli <- HttpClient$new(url = "http://api.crossref.org")
aa <- Paginator$new(client = cli, by = "query_params", limit_param = "rows",
  offset_param = "offset", limit = 50, limit_chunk = 10)

test_that("Paginator works", {
  skip_on_cran()

  expect_is(cli, "HttpClient")
  expect_is(Paginator, "R6ClassGenerator")

  expect_is(aa, "Paginator")
  expect_is(aa$.__enclos_env__$private$page, "function")
  expect_is(aa$parse, "function")
  expect_is(aa$content, "function")
  expect_is(aa$responses, "function")

  # before requests
  expect_equal(length(aa$content()), 0)
  expect_equal(length(aa$status()), 0)
  expect_equal(length(aa$status_code()), 0)
  expect_equal(length(aa$times()), 0)

  # after requests
  invisible(aa$get("works"))
  expect_equal(length(aa$content()), 5)
  expect_equal(length(aa$status()), 5)
  expect_equal(length(aa$status_code()), 5)
  expect_equal(length(aa$times()), 5)
})

test_that("Paginator fails well", {
  skip_on_cran()

  expect_error(Paginator$new(), "argument \"client\" is missing")
  expect_error(Paginator$new(cli), "'to' must be of length 1")
  expect_error(Paginator$new(cli, 5), "'by' has to be 'query_params' for now")
  expect_error(Paginator$new(5, "query_params"), 
    "'client' has to be an object of class 'HttpClient'")
})
