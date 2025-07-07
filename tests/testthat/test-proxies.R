skip_on_cran()
skip_if_offline(url_parse(hb())$domain)


test_that("proxy without http requests works", {
  aa <- proxy("http://97.77.104.22:3128")
  bb <- proxy("97.77.104.22:3128")
  cc <- proxy("http://97.77.104.22:3128", "foo", "bar")
  dd <- proxy("http://97.77.104.22:3128", "foo", "bar", auth = "digest")
  ee <- proxy("http://97.77.104.22:3128", "foo", "bar", auth = "ntlm")

  expect_s3_class(aa, "proxy")
  expect_type(unclass(aa), "list")
  expect_type(aa$proxy, "character")
  expect_type(aa$proxyport, "double")
  expect_type(aa$proxyauth, "double")

  expect_s3_class(bb, "proxy")
  expect_type(unclass(bb), "list")
  expect_type(bb$proxy, "character")
  expect_type(bb$proxyport, "double")
  expect_type(bb$proxyauth, "double")

  expect_s3_class(cc, "proxy")
  expect_type(unclass(cc), "list")
  expect_type(cc$proxy, "character")
  expect_type(cc$proxyport, "double")
  expect_type(cc$proxyauth, "double")

  expect_s3_class(dd, "proxy")
  expect_type(unclass(dd), "list")
  expect_type(dd$proxy, "character")
  expect_type(dd$proxyport, "double")
  expect_type(dd$proxyauth, "double")

  expect_s3_class(ee, "proxy")
  expect_type(unclass(ee), "list")
  expect_type(ee$proxy, "character")
  expect_type(ee$proxyport, "double")
  expect_type(ee$proxyauth, "double")
})

test_that("proxy - using in HttpClient", {
  aa <- HttpClient$new(
    url = "http://www.google.com",
    proxies = proxy("http://97.77.104.22:3128")
  )

  expect_s3_class(aa, "HttpClient")
  expect_s3_class(aa$proxies, "proxy")
})

test_that("proxy fails well", {
  expect_error(proxy(), "proxy URL not of correct form")
  expect_error(proxy(user = mtcars), "proxy URL not of correct form")
  expect_error(proxy("adff", user = 5), "user must be of class character")
  expect_error(proxy("adff", pwd = 5), "pwd must be of class character")
})
