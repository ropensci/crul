context("paths")

test_that("paths work", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$get(path = 'get')

  expect_is(aa, "HttpResponse")
  urlsp <- strsplit(aa$url, "/")[[1]]
  expect_equal(urlsp[length(urlsp)], "get")
  expect_equal(aa$status_code, 200)
})

test_that("path - multiple route paths work", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  bb <- cli$get('status/200')

  expect_is(bb, "HttpResponse")
  urlsp <- strsplit(bb$url, "/")[[1]]
  expect_equal(urlsp[4:5], c('status', '200'))
  expect_equal(bb$status_code, 200)
})

test_that("path - paths don't work if paths already on URL", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org/get/adsfasdf")
  bb <- cli$get('stuff')

  expect_is(bb, "HttpResponse")
  expect_equal(bb$status_code, 404)
  expect_true(grepl("stuff", bb$url))
  expect_false(grepl("adsfasdf", bb$url))
})

test_that("path - work with routes that have spaces", {
  skip_on_cran()

  cli <- HttpClient$new(url = "http://www.marinespecies.org")
  bb <- cli$get('rest/AphiaRecordsByName/Platanista gangetica')

  expect_is(bb, "HttpResponse")
  urlsp <- strsplit(bb$url, "/")[[1]]
  expect_equal(urlsp[length(urlsp)], 'Platanista%20gangetica')
})
