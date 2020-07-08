context("authenticate")

test_that("auth construction works", {
  skip_on_cran()

  basic <- auth(user = "foo", pwd = "bar", auth = "basic")
  digest <- auth(user = "foo", pwd = "bar", auth = "digest")
  ntlm <- auth(user = "foo", pwd = "bar", auth = "ntlm")
  any <- auth(user = "foo", pwd = "bar", auth = "any")

  expect_is(basic, "auth")
  expect_is(digest, "auth")
  expect_is(ntlm, "auth")
  expect_is(any, "auth")

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
  skip_on_cran()

  aa <- HttpClient$new(
    url = hb("/basic-auth/user/passwd"),
    auth = auth(user = "foo", pwd = "bar")
  )

  expect_is(aa, "HttpClient")
  expect_is(aa$auth, "auth")
  expect_equal(aa$auth$userpwd, "foo:bar")
  expect_equal(aa$auth$httpauth, 1)
})

test_that("auth works with HttpRequest", {
  skip_on_cran()

  aa <- HttpRequest$new(
    url = hb("/basic-auth/user/passwd"),
    auth = auth(user = "foo", pwd = "bar")
  )

  expect_is(aa, "HttpRequest")
  expect_is(aa$auth, "auth")
  expect_equal(aa$auth$userpwd, "foo:bar")
  expect_equal(aa$auth$httpauth, 1)
})

test_that("auth fails well", {
  skip_on_cran()
  
  expect_error(auth(), "argument \"user\" is missing")
  expect_error(auth(user = "asdf"), "argument \"pwd\" is missing")
  expect_error(auth(5, 5), "user must be of class character")
  expect_error(auth("adsf", 5), "pwd must be of class character")
  expect_error(
    auth("asdf", "asdf", 5), "inherits\\(x, \"character\"\\) is not TRUE")
})

