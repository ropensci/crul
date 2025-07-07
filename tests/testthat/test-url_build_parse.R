skip_if_offline(url_parse(hb())$domain)


test_that("url build works", {
  skip_on_cran()

  aa <- url_build(hb())
  bb <- url_build(hb(), "get")
  cc <- url_build(hb(), "get", list(foo = "bar"))

  expect_type(aa, "character")
  expect_match(aa, "http")

  expect_type(bb, "character")
  expect_match(bb, "http")
  expect_match(bb, "get")

  expect_type(cc, "character")
  expect_match(cc, "http")
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

  # length
  expect_error(url_build(rep(hb(), 2)), "length\\(url\\) == 1 is not TRUE")
  expect_error(
    url_build(hb(), c('foo', 'bar')),
    "length\\(path\\) <= 1 is not TRUE"
  )

  # query list is named
  expect_error(
    url_build("As", query = list(4, 5)),
    "all query elements must be named"
  )
})


test_that("url parse works", {
  skip_on_cran()

  aa <- url_parse(hb())
  bb <- url_parse(hb("/get?foo=bar"))
  cc <- url_parse(hb("/get?foo=bar&stuff=things"))

  expect_type(aa, "list")
  expect_named(
    aa,
    c('scheme', 'domain', 'port', 'path', 'parameter', 'fragment')
  )
  expect_type(aa$scheme, "character")
  expect_equal(aa$scheme, "https")
  expect_type(aa$domain, "character")
  expect_true(is.na(aa$path))
  expect_true(is.na(aa$parameter))

  expect_type(bb, "list")
  expect_named(
    bb,
    c('scheme', 'domain', 'port', 'path', 'parameter', 'fragment')
  )
  expect_type(bb$scheme, "character")
  expect_equal(bb$scheme, "https")
  expect_type(bb$domain, "character")
  expect_equal(bb$path, "get")
  expect_type(bb$parameter, "list")
  expect_equal(bb$parameter$foo, "bar")

  expect_type(cc, "list")
  expect_named(
    cc,
    c('scheme', 'domain', 'port', 'path', 'parameter', 'fragment')
  )
  expect_type(cc$scheme, "character")
  expect_equal(cc$scheme, "https")
  expect_type(cc$domain, "character")
  expect_equal(cc$path, "get")
  expect_type(cc$parameter, "list")
  expect_equal(cc$parameter$foo, "bar")
  expect_equal(cc$parameter$stuff, "things")
})

test_that("build and parse fails well", {
  skip_on_cran()

  # url param required
  expect_error(url_parse(), "argument \"url\" is missing")

  # scalar character required
  expect_error(url_parse(rep(hb(), 2)), "length\\(url\\) == 1 is not TRUE")
})
