skip_on_cran()
skip_if_offline(url_parse(hb())$domain)
context("HttpClient: query")

test_that("query works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$get('get', query = list(hello = "world"))

  expect_is(aa, "HttpResponse")
  expect_match(aa$url, "hello")
  expect_match(aa$url, "world")
  expect_match(jsonlite::fromJSON(aa$parse())$url, "hello")
  expect_match(jsonlite::fromJSON(aa$parse())$url, "world")
})

test_that("query - multiple params of same name work", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$get('get', query = list(hello = 5, hello = 6))

  expect_is(aa, "HttpResponse")
  expect_equal(length(gregexpr("hello", aa$url)[[1]]), 2)
  expect_equal(
    length(gregexpr("hello", jsonlite::fromJSON(aa$parse())$url)[[1]]),
    2
  )
})

test_that("query - length 0 query list works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$get('get', query = list())

  expect_is(aa, "HttpResponse")
  expect_false(grepl("\\?", aa$url))
})
