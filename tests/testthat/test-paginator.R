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


test_that("Paginator works with many different limit and limit_chunk combinations", {
  skip_on_cran()

  limit_param = "rows"
  offset_param = "start"

  aa <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 27, limit_chunk = 10)
  expect_equal(aa$.__enclos_env__$private$offset_iters, c(0, 10, 20))
  expect_equal(aa$.__enclos_env__$private$limit_chunks, c(10, 10, 7))

  bb <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 50, limit_chunk = 10)
  expect_equal(bb$.__enclos_env__$private$offset_iters, c(0, 10, 20, 30, 40))
  expect_equal(bb$.__enclos_env__$private$limit_chunks, c(10, 10, 10, 10, 10))

  cc <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 1050, limit_chunk = 20)
  expect_equal(cc$.__enclos_env__$private$offset_iters, seq(0, 1040, by = 20))
  expect_equal(cc$.__enclos_env__$private$limit_chunks, c(rep(20, floor(1050/20)), 10))

  dd <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 1049, limit_chunk = 20)
  expect_equal(dd$.__enclos_env__$private$offset_iters, seq(0, 1040, by = 20))
  expect_equal(dd$.__enclos_env__$private$limit_chunks, c(rep(20, floor(1049/20)), 9))

  ee <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 1051, limit_chunk = 20)
  expect_equal(ee$.__enclos_env__$private$offset_iters, seq(0, 1040, by = 20))
  expect_equal(ee$.__enclos_env__$private$limit_chunks, c(rep(20, floor(1051/20)), 11))

  ff <- Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
    offset_param = offset_param, limit = 1051, limit_chunk = 5)
  expect_equal(ff$.__enclos_env__$private$offset_iters, seq(0, 1050, by = 5))
  expect_equal(ff$.__enclos_env__$private$limit_chunks, c(rep(5, floor(1051/5)), 1))

})


test_that("Paginator fails well", {
  skip_on_cran()

  expect_error(Paginator$new(), "argument \"client\" is missing")
  expect_error(Paginator$new(cli), "argument \"limit_chunk\" is missing")
  expect_error(Paginator$new(cli, 5), "'by' has to be 'query_params' for now")
  expect_error(Paginator$new(5, "query_params"), 
    "'client' has to be an object of class 'HttpClient'")

  limit_param = "rows"
  offset_param = "start"
  
  # limit_chunk = 0 or not an integer
  expect_error(
    Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
      offset_param = offset_param, limit = 51, limit_chunk = 0),
    "'limit_chunk' must be an integer and > 0"
  )
  expect_error(
    Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
      offset_param = offset_param, limit = 51, limit_chunk = 1.5),
    "'limit_chunk' must be an integer and > 0"
  )

  # limit not an integer
  expect_error(
    Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
      offset_param = offset_param, limit = "stuff", limit_chunk = 10),
    "limit must be of class numeric, integer"
  )

  # limit_param must be character
  expect_error(
    Paginator$new(client = cli, by = "query_params", limit_param = 5,
      offset_param = offset_param, limit = 51, limit_chunk = 10),
    "limit_param must be of class character"
  )

  # limit_param must be character
  expect_error(
    Paginator$new(client = cli, by = "query_params", limit_param = limit_param,
      offset_param = 5, limit = 51, limit_chunk = 10),
    "offset_param must be of class character"
  )
})
