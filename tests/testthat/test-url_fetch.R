context("client: url_fetch")
url <- hb()
x <- HttpClient$new(url = url)
test_that("HttpClient url_fetch base url only", {
  skip_on_cran()

  expect_is(x$url_fetch(), "character")
  expect_match(x$url_fetch(), url)
  expect_match(x$url_fetch(), "http")
})

test_that("HttpClient url_fetch with base url and path", {
  skip_on_cran()

  expect_is(x$url_fetch('get'), "character")
  expect_match(x$url_fetch('get'), url)
  expect_match(x$url_fetch('get'), "/get")
  expect_match(x$url_fetch('get'), "http")

  expect_is(x$url_fetch('post'), "character")
  expect_match(x$url_fetch('post'), url)
  expect_match(x$url_fetch('post'), "/post")
  expect_match(x$url_fetch('post'), "http")

  expect_is(x$url_fetch('post'), "character")
  expect_match(x$url_fetch('post'), url)
  expect_match(x$url_fetch('post'), "/post")
  x$url_fetch('get', query = list(foo = "bar"))
})

test_that("HttpClient url_fetch with base url, path, query", {
  skip_on_cran()

  out <- x$url_fetch('get', query = list(foo = "bar"))

  expect_is(out, "character")
  expect_match(out, url)
  expect_match(out, "/get")
  expect_match(out, "http")
  expect_match(out, "?foo=bar")

  out <- x$url_fetch('get', query = list(foo = "bar food"))

  expect_is(out, "character")
  expect_match(out, url)
  expect_match(out, "/get")
  expect_match(out, "http")
  expect_match(out, "?foo=bar%20food")
})


context("HttpCLient: url_fetch w/ bigger numbers")
cr_url <- "https://api.crossref.org"
con <- HttpClient$new(url = cr_url)
test_that("HttpClient url_fetch w/ bigger numbers", {
  skip_on_cran()

  expect_match(con$url_fetch(query = list(limit = 0)),
    "limit=0")
  expect_match(con$url_fetch(query = list(limit = 100000)),
    "limit=100000")
  expect_match(con$url_fetch(query = list(limit = 200000)),
    "limit=200000")
  expect_match(con$url_fetch(query = list(limit = 300000)),
    "limit=300000")
  expect_match(con$url_fetch(query = list(limit = 400000)),
    "limit=400000")
})




context("paginator: url_fetch")
cr_url <- "https://api.crossref.org"
cli <- HttpClient$new(url = cr_url)
aa <- Paginator$new(client = cli, by = "limit_offset", limit_param = "rows",
  offset_param = "offset", limit = 500000, chunk = 100000)
test_that("Paginator url_fetch base url only", {
  skip_on_cran()

  expect_is(aa$url_fetch(), "character")
  expect_match(aa$url_fetch(), cr_url)
  expect_equal(length(aa$url_fetch()), 5)

  # offset query param should exist
  expect_match(aa$url_fetch(), "offset")
  # rows query param should exist
  expect_match(aa$url_fetch(), "rows")
  # offset different for every url
  expect_match(aa$url_fetch()[1], "offset=0")
  expect_match(aa$url_fetch()[2], "offset=100000")
  expect_match(aa$url_fetch()[3], "offset=200000")
  expect_match(aa$url_fetch()[4], "offset=300000")
  expect_match(aa$url_fetch()[5], "offset=400000")
  # rows same for every url
  expect_match(aa$url_fetch(), "rows=100000")
})

test_that("Paginator url_fetch with base url and path", {
  skip_on_cran()

  expect_is(aa$url_fetch("works"), "character")
  expect_match(aa$url_fetch("works"), cr_url)
  expect_equal(length(aa$url_fetch("works")), 5)
  expect_match(aa$url_fetch("works"), "/works")

  # offset query param should exist
  expect_match(aa$url_fetch("works"), "offset")
  # rows query param should exist
  expect_match(aa$url_fetch("works"), "rows")
})

test_that("Paginator url_fetch with base url, path, query", {
  skip_on_cran()

  out <- aa$url_fetch("works", query = list(query = "biology"))

  expect_is(out, "character")
  expect_match(out, cr_url)
  expect_match(out, "query=biology")
  expect_equal(length(out), 5)

  # offset query param should exist
  expect_match(aa$url_fetch("works"), "offset")
  # rows query param should exist
  expect_match(aa$url_fetch("works"), "rows")
})
