context("AsyncVaried")

test_that("AsyncVaried works", {
  skip_on_cran()

  expect_is(AsyncVaried, "R6ClassGenerator")

  req1 <- HttpRequest$new(url = "https://httpbin.org/get")$get()
  req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post()

  aa <- AsyncVaried$new(req1, req2)

  expect_is(aa, "AsyncVaried")
  expect_is(aa$.__enclos_env__$private$async_request, "function")
  expect_is(aa$parse, "function")
  expect_is(aa$content, "function")
  expect_is(aa$requests, "function")

  # before requests
  expect_equal(length(aa$content()), 0)
  expect_equal(length(aa$status()), 0)
  expect_equal(length(aa$status_code()), 0)
  expect_equal(length(aa$times()), 0)

  # after requests
  aa$request()
  expect_equal(length(aa$content()), 2)
  expect_equal(length(aa$status()), 2)
  expect_equal(length(aa$status_code()), 2)
  expect_equal(length(aa$times()), 2)
})

test_that("AsyncVaried fails well", {
  skip_on_cran()

  expect_error(AsyncVaried$new(), "must pass in at least one request")
  expect_error(AsyncVaried$new(5), "all inputs must be of class 'HttpRequest'")
})

context("AsyncVaried - order of results")
test_that("AsyncVaried - order", {
  skip_on_cran()

  req1 <- HttpRequest$new(url = "https://httpbin.org/get?a=5")$get()
  req2 <- HttpRequest$new(url = "https://httpbin.org/get?b=6")$get()
  req3 <- HttpRequest$new(url = "https://httpbin.org/get?c=7")$get()
  aa <- AsyncVaried$new(req1, req2, req3)
  aa$request()
  out <- aa$responses()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_is(out[[3]], "HttpResponse")

  expect_match(out[[1]]$url, "a=5")
  expect_match(out[[2]]$url, "b=6")
  expect_match(out[[3]]$url, "c=7")
})


context("AsyncVaried - disk")
test_that("AsyncVaried - writing to disk works", {
  skip_on_cran()

  f <- tempfile()
  g <- tempfile()
  req1 <- HttpRequest$new(url = "https://httpbin.org/get")$get(disk = f)
  req2 <- HttpRequest$new(url = "https://httpbin.org/post")$post(disk = g)
  req3 <- HttpRequest$new(url = "https://httpbin.org/get")$get()
  out <- AsyncVaried$new(req1, req2, req3)
  out$request()
  cont <- out$content()
  lines_f <- readLines(f)
  lines_g <- readLines(g)

  expect_is(out, "AsyncVaried")

  expect_is(cont, "list")
  expect_is(cont[[1]], "raw")
  expect_identical(cont[[1]], raw(0))
  expect_is(cont[[2]], "raw")
  expect_identical(cont[[2]], raw(0))
  expect_is(cont[[3]], "raw")
  expect_gt(length(cont[[3]]), 0)

  expect_is(lines_f, "character")
  expect_gt(length(lines_f), 0)

  expect_is(lines_g, "character")
  expect_gt(length(lines_g), 0)

  # cleanup
  closeAllConnections()
})


context("AsyncVaried - stream")
test_that("AsyncVaried - streaming to disk works", {
  skip_on_cran()

  lst <- c()
  fun <- function(x) lst <<- c(lst, x)
  req1 <- HttpRequest$new(url = "https://httpbin.org/get"
  )$get(query = list(foo = "bar"), stream = fun)
  req2 <- HttpRequest$new(url = "https://httpbin.org/get"
  )$get(query = list(hello = "world"), stream = fun)
  out <- AsyncVaried$new(req1, req2)
  suppressWarnings(out$request())

  expect_is(out, "AsyncVaried")

  expect_identical(out$responses()[[1]]$content, raw(0))
  expect_identical(out$responses()[[2]]$content, raw(0))

  expect_is(lst, "raw")
  expect_is(rawToChar(lst), "character")
  expect_match(rawToChar(lst), "application/json")
})
