skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("AsyncVaried works", {
  expect_s3_class(AsyncVaried, "R6ClassGenerator")

  req1 <- HttpRequest$new(url = hb("/get"))$get()
  req2 <- HttpRequest$new(url = hb("/post"))$post()

  aa <- AsyncVaried$new(req1, req2)

  expect_s3_class(aa, "AsyncVaried")
  expect_type(aa$.__enclos_env__$private$async_request, "closure")
  expect_type(aa$parse, "closure")
  expect_type(aa$content, "closure")
  expect_type(aa$requests, "closure")

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
  expect_type(aa$responses()[[1]]$response_headers, "list")
  expect_named(aa$responses()[[1]]$response_headers)
  expect_type(aa$responses()[[1]]$response_headers_all, "list")
  expect_named(aa$responses()[[1]]$response_headers_all, NULL)
})

test_that("AsyncVaried fails well", {
  expect_error(AsyncVaried$new(), "must pass in at least one request")
  expect_error(AsyncVaried$new(5), "all inputs must be of class 'HttpRequest'")
})

test_that("AsyncVaried - order", {
  req1 <- HttpRequest$new(url = hb("/get?a=5"))$get()
  req2 <- HttpRequest$new(url = hb("/get?b=6"))$get()
  req3 <- HttpRequest$new(url = hb("/get?c=7"))$get()
  aa <- AsyncVaried$new(req1, req2, req3)
  aa$request()
  out <- aa$responses()

  expect_s3_class(out, "asyncresponses")
  expect_s3_class(out[[1]], "HttpResponse")
  expect_s3_class(out[[2]], "HttpResponse")
  expect_s3_class(out[[3]], "HttpResponse")

  expect_match(out[[1]]$url, "a=5")
  expect_match(out[[2]]$url, "b=6")
  expect_match(out[[3]]$url, "c=7")
})


test_that("AsyncVaried - writing to disk works", {
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

  expect_s3_class(out, "AsyncVaried")

  expect_type(cont, "list")
  expect_type(cont[[1]], "raw")
  expect_identical(cont[[1]], raw(0))
  expect_type(cont[[2]], "raw")
  expect_identical(cont[[2]], raw(0))
  expect_type(cont[[3]], "raw")
  expect_gt(length(cont[[3]]), 0)

  expect_type(lines_f, "character")
  expect_gt(length(lines_f), 0)

  expect_type(lines_g, "character")
  expect_gt(length(lines_g), 0)

  # cleanup
  closeAllConnections()
})


test_that("AsyncVaried - streaming to disk works", {
  lst <- c()
  fun <- function(x) lst <<- append(lst, list(x))
  req1 <- HttpRequest$new(url = hb("/get"))$get(
    query = list(foo = "bar"),
    stream = fun
  )
  req2 <- HttpRequest$new(url = hb("/get"))$get(
    query = list(hello = "world"),
    stream = fun
  )
  out <- AsyncVaried$new(req1, req2)
  suppressWarnings(out$request())

  expect_s3_class(out, "AsyncVaried")

  expect_identical(out$responses()[[1]]$content, raw(0))
  expect_identical(out$responses()[[2]]$content, raw(0))

  expect_type(lst, "list")
  expect_type(lst[[1]], "list")
  expect_type(lst[[2]], "list")
  expect_type(rawToChar(lst[[1]]$content), "character")
  expect_type(rawToChar(lst[[2]]$content), "character")
})

test_that("AsyncVaried - with basic auth works", {
  url <- hb("/basic-auth/user/passwd")
  auth <- auth(user = "user", pwd = "passwd")
  reqlist <- list(
    HttpRequest$new(url = url, auth = auth)$get(),
    HttpRequest$new(url = url, auth = auth)$get(query = list(a = 5)),
    HttpRequest$new(url = url, auth = auth)$get(query = list(b = 3))
  )
  out <- AsyncVaried$new(.list = reqlist)
  out$request()

  expect_s3_class(out, "AsyncVaried")

  expect_equal(length(out$responses()), 3)

  resps <- out$responses()
  expect_s3_class(resps[[1]]$request$auth, "auth")
  expect_equal(resps[[1]]$request$auth$userpwd, "user:passwd")
  expect_equal(resps[[1]]$request$auth$httpauth, 1)
})

test_that("AsyncVaried - failure behavior", {
  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(),
    HttpRequest$new(url = base_url)$head(),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$head()
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_s3_class(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 3)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 200)
  expect_equal(resps[[3]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_true(resps[[2]]$success())
  expect_false(resps[[3]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")
})


# disk and stream behave the same was as w/o either of them
test_that("AsyncVaried - failure behavior", {
  f <- tempfile()
  g <- tempfile()
  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(disk = f),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$get(disk = g)
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_s3_class(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 2)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_false(resps[[2]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")

  # cleanup
  closeAllConnections()
})

test_that("AsyncVaried - failure behavior", {
  lst <- c()
  fun <- function(x) lst <<- c(lst, x)
  reqlist <- list(
    HttpRequest$new(url = "http://stuffthings.gvb")$get(stream = fun),
    HttpRequest$new(url = base_url, opts = list(timeout_ms = 10))$get(
      stream = fun
    )
  )
  tmp <- AsyncVaried$new(.list = reqlist)
  tmp$request()

  expect_s3_class(tmp, "AsyncVaried")
  expect_equal(length(tmp$responses()), 2)

  resps <- tmp$responses()
  expect_equal(resps[[1]]$status_code, 0)
  expect_equal(resps[[2]]$status_code, 0)

  expect_false(resps[[1]]$success())
  expect_false(resps[[2]]$success())

  expect_match(resps[[1]]$parse("UTF-8"), "resolve host")
})

# verb method works
test_that("AsyncVaried verb method works", {
  req1 <- HttpRequest$new(url = hb("/get"))$verb('get')
  req2 <- HttpRequest$new(url = hb("/post"))$verb('post')

  aa <- AsyncVaried$new(req1, req2)
  aa$request()
  expect_equal(aa$responses()[[1]]$method, 'get')
  expect_equal(aa$responses()[[2]]$method, 'post')
})

# verb method works
test_that("AsyncVaried verb retry", {
  req1 <- HttpRequest$new(url = hb("/get"))$retry('get')
  req2 <- HttpRequest$new(url = hb("/post"))$retry('post')

  aa <- AsyncVaried$new(req1, req2)
  aa$request()
  expect_equal(aa$responses()[[1]]$method, 'get')
  expect_equal(aa$responses()[[2]]$method, 'post')
})
