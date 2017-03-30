context("headers")

test_that("headers work - just default headers", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$get('get')

  expect_is(aa, "HttpResponse")
  expect_named(aa$request_headers, 'useragent')
})

test_that("headers work - user headers passed", {
  skip_on_cran()

  cli <- HttpClient$new(
    url = "https://httpbin.org",
    headers = list(hello = "world")
  )
  bb <- cli$get('get')

  expect_is(bb, "HttpResponse")
  expect_named(bb$request_headers, c('useragent', 'hello'))
  expect_true(
    any(grepl("Hello", names(jsonlite::fromJSON(bb$parse())$headers))))
})
