context("request: get")

test_that("get request works", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$get("get")

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())
})

test_that("get request - query parameters", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  querya <- list(a = "Asdfadsf", hello = "world")
  aa <- cli$get("get", query = querya)

  expect_is(aa, "HttpResponse")
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  library(urltools)
  params <- unlist(lapply(
    strsplit(urltools::url_parse(aa$request$url$url)$parameter, "&")[[1]],
    function(x) {
      tmp <- strsplit(x, "=")[[1]]
      as.list(stats::setNames(tmp[2], tmp[1]))
    }
  ), FALSE)
  expect_equal(params, querya)
})
