context("url build")

test_that("url build works", {
  skip_on_cran()

  aa <- url_build(hb())
  bb <- url_build(hb(), "get")
  cc <- url_build(hb(), "get", list(foo = "bar"))

  expect_is(aa, "character")
  expect_match(aa, "https")
  expect_match(aa, "httpbin.org")

  expect_is(bb, "character")
  expect_match(bb, "https")
  expect_match(bb, "httpbin.org")
  expect_match(bb, "get")

  expect_is(cc, "character")
  expect_match(cc, "https")
  expect_match(cc, "httpbin.org")
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

  aa <- url_parse(hb())
  bb <- url_parse(hb("/get?foo=bar"))
  cc <- url_parse(hb("/get?foo=bar&stuff=things"))

  expect_is(aa, "list")
  expect_named(aa, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(aa$scheme, "character")
  expect_equal(aa$scheme, "https")
  expect_is(aa$domain, "character")
  expect_true(is.na(aa$path))
  expect_true(is.na(aa$parameter))

  expect_is(bb, "list")
  expect_named(bb, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(bb$scheme, "character")
  expect_equal(bb$scheme, "https")
  expect_is(bb$domain, "character")
  expect_equal(bb$path, "get")
  expect_is(bb$parameter, "list")
  expect_equal(bb$parameter$foo, "bar")

  expect_is(cc, "list")
  expect_named(cc, c('scheme', 'domain', 'port', 'path', 'parameter',
                     'fragment'))
  expect_is(cc$scheme, "character")
  expect_equal(cc$scheme, "https")
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
