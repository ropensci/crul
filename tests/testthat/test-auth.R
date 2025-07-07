skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("auth construction works", {
  basic <- auth(user = "foo", pwd = "bar", auth = "basic")
  digest <- auth(user = "foo", pwd = "bar", auth = "digest")
  ntlm <- auth(user = "foo", pwd = "bar", auth = "ntlm")
  any <- auth(user = "foo", pwd = "bar", auth = "any")

  expect_s3_class(basic, "auth")
  expect_s3_class(digest, "auth")
  expect_s3_class(ntlm, "auth")
  expect_s3_class(any, "auth")

  expect_named(basic, c('userpwd', 'httpauth'))
  expect_named(digest, c('userpwd', 'httpauth'))
  expect_named(ntlm, c('userpwd', 'httpauth'))
  expect_named(any, c('userpwd', 'httpauth'))

  expect_equal(attr(basic, "type"), "basic")
  expect_equal(attr(digest, "type"), "digest")
  expect_equal(attr(ntlm, "type"), "ntlm")
  expect_equal(attr(any, "type"), "any")
})

test_that("auth works with HttpClient", {
  aa <- HttpClient$new(
    url = hb("/basic-auth/user/passwd"),
    auth = auth(user = "foo", pwd = "bar")
  )

  expect_s3_class(aa, "HttpClient")
  expect_s3_class(aa$auth, "auth")
  expect_equal(aa$auth$userpwd, "foo:bar")
  expect_equal(aa$auth$httpauth, 1)
})

test_that("auth works with HttpRequest", {
  aa <- HttpRequest$new(
    url = hb("/basic-auth/user/passwd"),
    auth = auth(user = "foo", pwd = "bar")
  )

  expect_s3_class(aa, "HttpRequest")
  expect_s3_class(aa$auth, "auth")
  expect_equal(aa$auth$userpwd, "foo:bar")
  expect_equal(aa$auth$httpauth, 1)
})

test_that("auth fails well", {
  expect_error(auth(), "argument \"user\" is missing")
  expect_error(auth(user = "asdf"), "argument \"pwd\" is missing")
  expect_error(auth(5, 5), "user must be of class character")
  expect_error(auth("adsf", 5), "pwd must be of class character")
  expect_error(
    auth("asdf", "asdf", 5),
    "inherits\\(x, \"character\"\\) is not TRUE"
  )
})
