context("url build")

test_that("url build works", {
  skip_on_cran()

  aa <- url_build("http://localhost:80")
  bb <- url_build("http://localhost:80", "get")
  cc <- url_build("http://localhost:80", "get", list(foo = "bar"))

  expect_is(aa, "character")
  expect_match(aa, "http")
  expect_match(aa, "localhost")

  expect_is(bb, "character")
  expect_match(bb, "http")
  expect_match(bb, "localhost")
  expect_match(bb, "get")

  expect_is(cc, "character")
  expect_match(cc, "http")
  expect_match(cc, "localhost")
  expect_match(cc, "?foo=bar")
})

test_that("build fails well", {
  skip_on_cran()

  # url param required
  expect_error(url_build(), "argument \"url\" is missing")

  # wrong types
  expect_error(url_build(5), "url must be of class character")
  expect_error(url_build("ASDf", path = 5), "path must be of class character")
  expect_error(url_build("adff", query = 5), "query must be of class list")

  # query list is named
  expect_error(url_build("As", query = list(4, 5)),
               "all query elements must be named")
})


context("url parse")

test_that("url parse works", {
  skip_on_cran()

  aa <- url_parse("http://localhost:80")
  bb <- url_parse("http://localhost:80/get?foo=bar")
  cc <- url_parse("http://localhost:80/get?foo=bar&stuff=things")

  expect_is(aa, "list")
  expect_named(aa, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(aa$scheme, "character")
  expect_equal(aa$scheme, "http")
  expect_is(aa$domain, "character")
  expect_true(is.na(aa$path))
  expect_true(is.na(aa$parameter))

  expect_is(bb, "list")
  expect_named(bb, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(bb$scheme, "character")
  expect_equal(bb$scheme, "http")
  expect_is(bb$domain, "character")
  expect_equal(bb$path, "get")
  expect_is(bb$parameter, "list")
  expect_equal(bb$parameter$foo, "bar")

  expect_is(cc, "list")
  expect_named(cc, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(cc$scheme, "character")
  expect_equal(cc$scheme, "http")
  expect_is(cc$domain, "character")
  expect_equal(cc$path, "get")
  expect_is(cc$parameter, "list")
  expect_equal(cc$parameter$foo, "bar")
  expect_equal(cc$parameter$stuff, "things")
})

test_that("parse fails well", {
  skip_on_cran()

  # url param required
  expect_error(url_build(), "argument \"url\" is missing")

  # wrong types
  expect_error(url_build(5), "url must be of class character")
  expect_error(url_build("ASDf", path = 5), "path must be of class character")
  expect_error(url_build("adff", query = 5), "query must be of class list")

  # query list is named
  expect_error(url_build("As", query = list(4, 5)),
               "all query elements must be named")
})
