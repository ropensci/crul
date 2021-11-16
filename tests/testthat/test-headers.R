context("headers: default headers")
test_that("headers work - just default headers", {
  skip_on_cran()

  cli <- HttpClient$new(url = hb())
  aa <- cli$get('get')

  expect_is(aa, "HttpResponse")
  expect_named(aa$request_headers, c('User-Agent', 'Accept-Encoding', 'Accept'))
})

context("headers: user defined headers")
test_that("headers work - user headers passed", {
  skip_on_cran()

  cli <- HttpClient$new(
    url = hb(),
    headers = list(hello = "world")
  )
  bb <- cli$get('get')

  expect_is(bb, "HttpResponse")
  expect_named(bb$request_headers, c('User-Agent', 'Accept-Encoding',
                                     'Accept', 'hello'))
  expect_true(
    any(grepl("Hello", names(jsonlite::fromJSON(bb$parse("UTF-8"))$headers))))
})

context("headers: all response headers")
test_that("headers - all response headers, WITH redirect", {
  skip_on_cran()

  x <- HttpClient$new("https://doi.org/10.1007/978-3-642-40455-9_52-1")
  bb <- x$get()

  # response headers are the final set of headers and are named
  expect_is(bb, "HttpResponse")
  expect_is(bb$response_headers, "list")
  expect_named(bb$response_headers)

  # response headers all are all headers and are not named
  expect_is(bb$response_headers_all, "list")
  expect_named(bb$response_headers_all, NULL)
  # individual header sets are named 
  expect_is(bb$response_headers_all[[1]], "list")
  expect_named(bb$response_headers_all[[1]])
  # response_headers == the last response_headers_all list
  expect_identical(
    bb$response_headers, 
    bb$response_headers_all[[length(bb$response_headers_all)]]
  )
  # for redirects, intermediate headers have 3** series status codes
  expect_true(
    any(grepl("3[0-9]{2}", 
      vapply(bb$response_headers_all, "[[", "", "status"))))
})

test_that("headers - all response headers, WITHOUT redirect", {
  skip_on_cran()

  x <- HttpClient$new(url = hb())
  bb <- x$get()

  # response headers are the final set of headers and are named
  expect_is(bb, "HttpResponse")
  expect_is(bb$response_headers, "list")
  expect_named(bb$response_headers)

  # response headers all are all headers and are not named
  expect_is(bb$response_headers_all, "list")
  expect_named(bb$response_headers_all, NULL)
  # individual header sets are named 
  expect_is(bb$response_headers_all[[1]], "list")
  expect_named(bb$response_headers_all[[1]])
  # response_headers == the last response_headers_all list
  expect_identical(
    bb$response_headers, 
    bb$response_headers_all[[length(bb$response_headers_all)]]
  )
  # w/o redirects, no 3** series status codes
  expect_false(
    any(grepl("3[0-9]{2}", 
      vapply(bb$response_headers_all, "[[", "", "status"))))
  # w/o redirects, only 1 header set
  expect_equal(length(bb$response_headers_all), 1)
})

context("headers: non-UTF-8 headers")
test_that("headers - non-UTF-8 headers from Crossref ('link' header)", {
  skip_on_cran()

  x <- HttpClient$new(url = 'https://doi.org/10.1126/science.aax9044',
    opts = list(followlocation = 1), headers = list(Accept = "application/x-bibtex"))
  bb <- x$get()

  # response headers are the final set of headers and are named
  expect_is(bb, "HttpResponse")
  expect_is(bb$response_headers, "list")
  expect_named(bb$response_headers)

  # includes link header
  expect_is(bb$response_headers$link, "character")
})
