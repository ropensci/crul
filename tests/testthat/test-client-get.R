skip_on_cran()
skip_if_offline(url_parse(hb())$domain)
context("HttpClient: get")

test_that("get request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$get("get")

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "get")
  expect_is(aa$parse, "function")
  expect_is(suppressMessages(aa$parse()), "character")
  expect_true(aa$success())

  # headers
  expect_is(aa$response_headers, "list")
  expect_named(aa$response_headers)
  expect_is(aa$response_headers_all, "list")
  expect_named(aa$response_headers_all, NULL)
  ## identical when no intermediate headers
  expect_identical(aa$response_headers, aa$response_headers_all[[1]])
})

test_that("get request - query parameters", {
  cli <- HttpClient$new(url = hb())
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

test_that("with auth works", {
  cli <- HttpClient$new(url = hb(), auth = auth("foo", "bar"))
  aa <- cli$get("/basic-auth/foo/bar")

  expect_is(aa, "HttpResponse")
  expect_equal(aa$method, "get")
  expect_true(aa$success())
  expect_equal(aa$status_code, 200)
  expect_equal(aa$request$options$userpwd, "foo:bar")
})
