skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

context("HttpClient")
test_that("HttpClient works", {
  expect_is(HttpClient, "R6ClassGenerator")

  aa <- HttpClient$new(url = hb())

  expect_is(aa, "HttpClient")
  expect_null(aa$handle)
  expect_length(aa$opts, 0)
  expect_is(aa$url, "character")
  expect_is(aa$.__enclos_env__$private$make_request, "function")
  expect_is(aa$post, "function")
  expect_is(aa$get, "function")
})

test_that("HttpClient fails well", {
  expect_error(HttpClient$new(), "need one of url or handle")
})

test_that("HttpClient print method", {
  aa <- HttpClient$new(
    url = hb(),
    opts = list(verbose = TRUE),
    headers = list(foo = "bar"),
    auth = auth(user = "foo", pwd = "bar", auth = "basic"),
    proxies = proxy("http://97.77.104.22:3128")
  )

  expect_is(aa$print, "function")
  expect_output(aa$print(), "crul connection")
  expect_output(aa$print(), "verbose: TRUE")
  expect_output(aa$print(), "auth: FALSE")
  expect_output(aa$print(), "- foo:bar")
  expect_output(aa$print(), "type:  1")
  expect_output(aa$print(), "foo: bar")
  expect_output(aa$print(), "progress: FALSE")
})


context("HttpClient - disk")
test_that("HttpClient works", {
  aa <- HttpClient$new(url = hb())
  f <- tempfile()
  res <- aa$get("get", disk = f)
  lns <- readLines(res$content, n = 10)

  expect_is(aa, "HttpClient")
  expect_is(res$content, "character")
  expect_gt(length(lns), 0)

  unlink(f)
})

test_that("HttpClient disk fails well", {
  aa <- HttpClient$new(url = hb())
  expect_error(aa$get("get", disk = 5), "invalid 'path' argument")
})


context("HttpClient - stream")
test_that("stream works", {
  aa <- HttpClient$new(url = hb())
  expect_output(
    res <- aa$get('stream/50', stream = function(x) cat(rawToChar(x))),
    "headers"
  )

  expect_is(res, "HttpResponse")
  expect_null(res$content)
})

test_that("stream fails well", {
  aa <- HttpClient$new(url = hb())
  expect_error(aa$get("get", stream = 5), "could not find function \"fun\"")
})


context("HttpClient - failure behavior")
test_that("HttpClient - failure behavior", {
  # url doesn't exist - could not resolve host
  conn <- HttpClient$new("http://stuffthings.gvb")
  expect_error(conn$get(), "resolve host")
})


test_that("parse() works with disk usage", {
  f <- tempfile(fileext = ".json")
  out <- crul::HttpClient$new(hb("/get"))$get(disk = f)
  expect_is(out$parse(), "character")
  expect_match(out$parse(), "headers")
})

test_that("parse() works with stream usage", {
  lst <- list()
  fun <- function(x) lst <<- append(lst, list(x))
  out <- crul::HttpClient$new(hb("/get"))$get(stream = fun)
  expect_equal(out$parse(), raw(0))
})
