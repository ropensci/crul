context("AsyncQueue: basic structure")
test_that("AsyncQueue basic structure", {
  skip_on_cran()

  expect_is(AsyncQueue, "R6ClassGenerator")

  req1 <- HttpRequest$new(url = hb("/get"))$get()
  req2 <- HttpRequest$new(url = hb("/post"))$post()

  aa <- AsyncQueue$new(req1, req2, sleep = 5)

  expect_is(aa, "AsyncQueue")
  expect_is(aa$.__enclos_env__$private$async_request, "function")
  expect_is(aa$parse, "function")
  expect_is(aa$content, "function")
  expect_is(aa$requests, "function")
  expect_type(aa$bucket_size, "double")
  expect_type(aa$sleep, "double")
  expect_null(aa$req_per_min)

  # before requests
  expect_equal(length(aa$content()), 0)
  expect_equal(length(aa$status()), 0)
  expect_equal(length(aa$status_code()), 0)
  expect_equal(length(aa$times()), 0)

  # after requests
  aa$request()
  expect_equal(length(aa$responses()), 2)
  expect_is(aa$responses()[[1]], "HttpResponse")
  # expect_equal(length(aa$status()), 2)
  # expect_equal(length(aa$status_code()), 2)
  # expect_equal(length(aa$times()), 2)

  # response_headers and response_headers_all 
  expect_is(aa$responses()[[1]]$response_headers, "list")
  expect_named(aa$responses()[[1]]$response_headers)
  expect_is(aa$responses()[[1]]$response_headers_all, "list")
  expect_named(aa$responses()[[1]]$response_headers_all, NULL)
})

context("AsyncQueue: fails well")
test_that("AsyncQueue fails well", {
  skip_on_cran()

  expect_error(AsyncQueue$new(), "must pass in at least one request")
  expect_error(AsyncQueue$new(5), "all inputs must be of class 'HttpRequest'")
  expect_error(AsyncQueue$new(HttpRequest$new(url = hb("/get"))$get()),
    "must set")
})

reqlist <- list(
  HttpRequest$new(url = "https://httpbin.org/get")$get(),
  HttpRequest$new(url = "https://httpbin.org/post")$post(),
  HttpRequest$new(url = "https://httpbin.org/put")$put(),
  HttpRequest$new(url = "https://httpbin.org/delete")$delete(),
  HttpRequest$new(url = "https://httpbin.org/get?g=5")$get(),
  HttpRequest$new(
    url = "https://httpbin.org/post")$post(body = list(y = 9)),
  HttpRequest$new(
    url = "https://httpbin.org/get")$get(query = list(hello = "world")),
  HttpRequest$new(url = "https://ropensci.org")$get(),
  HttpRequest$new(url = "https://ropensci.org/about")$get(),
  HttpRequest$new(url = "https://ropensci.org/packages")$get(),
  HttpRequest$new(url = "https://ropensci.org/community")$get(),
  HttpRequest$new(url = "https://ropensci.org/blog")$get(),
  HttpRequest$new(url = "https://ropensci.org/careers")$get()
)

context("AsyncQueue: sleep parameter")
test_that("AsyncQueue sleep parameter", {
  skip_on_cran()

  out <- AsyncQueue$new(.list = reqlist, bucket_size = 5, sleep = 3)
  expect_equal(out$bucket_size, 5)
  expect_equal(out$sleep, 3)
  expect_equal(length(out$responses()), 0)

  # should take at least 6 seconds: 3 sec sleep * 2 sleep periods
  z <- system.time(out$request())
  expect_gt(z[['elapsed']], 6)
  
  # after requests sent off
  expect_equal(length(out$requests()), 13)
  resp <- out$responses()
  expect_equal(length(resp), 13)
  for (i in seq_along(resp)) expect_is(resp[[i]], "HttpResponse")
  for (i in seq_along(resp)) expect_equal(resp[[i]]$status_code, 200)
})

context("AsyncQueue: req_per_min parameter")
test_that("AsyncQueue req_per_min parameter", {
  skip_on_cran()
  skip_on_ci()

  out <- AsyncQueue$new(.list = reqlist, req_per_min = 10)
  expect_equal(out$bucket_size, 10)
  expect_null(out$sleep)
  expect_equal(out$req_per_min, 10)
  expect_equal(length(out$responses()), 0)

  # FIXME: not doing actual requests as would take 1 min
  # z <- system.time(out$request())
  # expect_gt(z[['elapsed']], 6)
  
  # # after requests sent off
  # expect_equal(length(out$requests()), 13)
  # resp <- out$responses()
  # expect_equal(length(resp), 13)
  # for (i in seq_along(resp)) expect_is(resp[[i]], "HttpResponse")
  # for (i in seq_along(resp)) expect_equal(resp[[i]]$status_code, 200)
})
