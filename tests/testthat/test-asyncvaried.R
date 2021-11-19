context("AsyncVaried")

test_that("AsyncVaried works", {
  skip_on_cran()

  expect_is(AsyncVaried, "R6ClassGenerator")

  req1 <- HttpRequest$new(url = hb("/get"))$get()
  req2 <- HttpRequest$new(url = hb("/post"))$post()

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

  # response_headers and response_headers_all 
  expect_is(aa$responses()[[1]]$response_headers, "list")
  expect_named(aa$responses()[[1]]$response_headers)
  expect_is(aa$responses()[[1]]$response_headers_all, "list")
  expect_named(aa$responses()[[1]]$response_headers_all, NULL)
})

test_that("AsyncVaried fails well", {
  skip_on_cran()

  expect_error(AsyncVaried$new(), "must pass in at least one request")
  expect_error(AsyncVaried$new(5), "all inputs must be of class 'HttpRequest'")
})

context("AsyncVaried - order of results")
test_that("AsyncVaried - order", {
  skip_on_cran()

  req1 <- HttpRequest$new(url = hb("/get?a=5"))$get()
  req2 <- HttpRequest$new(url = hb("/get?b=6"))$get()
  req3 <- HttpRequest$new(url = hb("/get?c=7"))$get()
  aa <- AsyncVaried$new(req1, req2, req3)
  aa$request()
  out <- aa$responses()

  expect_is(out, "asyncresponses")
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
  req1 <- HttpRequest$new(url = hb("/get"))$get(disk = f)
  req2 <- HttpRequest$new(url = hb("/post"))$post(disk = g)
  req3 <- HttpRequest$new(url = hb("/get"))$get()
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
  fun <- function(x) lst <<- append(lst, list(x))
  req1 <- HttpRequest$new(url = hb("/get")
  )$get(query = list(foo = "bar"), stream = fun)
  req2 <- HttpRequest$new(url = hb("/get")
  )$get(query = list(hello = "world"), stream = fun)
  out <- AsyncVaried$new(req1, req2)
  suppressWarnings(out$request())

  expect_is(out, "AsyncVaried")

  expect_identical(out$responses()[[1]]$content, raw(0))
  expect_identical(out$responses()[[2]]$content, raw(0))

  expect_is(lst, "list")
  expect_is(lst[[1]], "list")
  expect_is(lst[[2]], "list")
  expect_is(rawToChar(lst[[1]]$content), "character")
  expect_is(rawToChar(lst[[2]]$content), "character")
})


context("AsyncVaried - basic auth")
test_that("AsyncVaried - basic auth works", {
  skip_on_cran()

  url <- hb("/basic-auth/user/passwd")
  auth <- auth(user = "user", pwd = "passwd")
  reqlist <- list(
    HttpRequest$new(url = url, auth = auth)$get(),
    HttpRequest$new(url = url, auth = auth)$get(query = list(a=5)),
    HttpRequest$new(url = url, auth = auth)$get(query = list(b=3))
  )
  out <- AsyncVaried$new(.list = reqlist)
  out$request()

  expect_is(out, "AsyncVaried")

  expect_equal(length(out$responses()), 3)

  resps <- out$responses()
  expect_is(resps[[1]]$request$auth, "auth")
  expect_equal(resps[[1]]$request$auth$userpwd, "user:passwd")
  expect_equal(resps[[1]]$request$auth$httpauth, 1)
})



context("AsyncVaried - failure behavior w/ bad URLs/etc.")
test_that("AsyncVaried - failure behavior", {
  skip_on_cran()

  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(),
    HttpRequest$new(url = base_url)$head(),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$head()
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_is(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 3)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 200)
  expect_equal(resps[[3]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_true(resps[[2]]$success())
  expect_false(resps[[3]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")
  expect_true(grepl("time", resps[[3]]$parse("UTF-8"), ignore.case = TRUE))
})


# disk and stream behave the same was as w/o either of them
context("AsyncVaried - failure behavior w/ bad URLs/etc. - disk")
test_that("AsyncVaried - failure behavior", {
  skip_on_cran()

  f <- tempfile()
  g <- tempfile()
  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(disk = f),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$get(disk = g)
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_is(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 2)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_false(resps[[2]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")
  expect_true(grepl("time", resps[[2]]$parse("UTF-8"), ignore.case = TRUE))
  
  # cleanup
  closeAllConnections()
})

# disk and stream behave the same was as w/o either of them
context("AsyncVaried - failure behavior w/ bad URLs/etc. - stream")
test_that("AsyncVaried - failure behavior", {
  skip_on_cran()

  lst <- c()
  fun <- function(x) lst <<- c(lst, x)
  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(stream = fun),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$get(stream = fun)
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_is(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 2)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_false(resps[[2]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")
  expect_true(grepl("time", resps[[2]]$parse("UTF-8"), ignore.case = TRUE))
})

# verb method works
test_that("AsyncVaried verb method works", {
  skip_on_cran()

  req1 <- HttpRequest$new(url = hb("/get"))$verb('get')
  req2 <- HttpRequest$new(url = hb("/post"))$verb('post')

  aa <- AsyncVaried$new(req1, req2)
  aa$request()
  expect_equal(aa$responses()[[1]]$method, 'get')
  expect_equal(aa$responses()[[2]]$method, 'post')
})
