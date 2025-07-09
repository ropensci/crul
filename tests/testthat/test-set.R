skip_if_offline(url_parse(hb())$domain)

test_that("crul_settings structure", {
  skip_on_cran()

  expect_type(crul_settings, "closure")

  aa <- crul_settings()

  expect_s3_class(aa, "ls_str")
  expect_null(names(aa))
  expect_equal(crul_settings(TRUE), crul_settings(FALSE))
})

#reset
crul_settings(reset = TRUE)


test_that("set_opts works", {
  skip_on_cran()

  expect_type(set_opts, "closure")

  # without any curl options set
  aa <- crul_settings()
  expect_length(aa, 0)

  # with empty curl options set
  set_opts()
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("opts"))

  # a single setting: timeout_ms
  set_opts(timeout_ms = 1000)
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("opts"))
  expect_named(get("opts", envir = crul_opts), 'timeout_ms')
  expect_equal(get("opts", envir = crul_opts)$timeout_ms, 1000)

  # resetting a previously set option
  set_opts(timeout_ms = 4000)
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("opts"))
  expect_named(get("opts", envir = crul_opts), 'timeout_ms')
  expect_equal(get("opts", envir = crul_opts)$timeout_ms, 4000)

  # verbose
  set_opts(verbose = TRUE)
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("opts"))
  expect_named(get("opts", envir = crul_opts), c('timeout_ms', 'verbose'))
  expect_equal(get("opts", envir = crul_opts)$timeout_ms, 4000)
  expect_true(get("opts", envir = crul_opts)$verbose)
})
#reset
crul_settings(reset = TRUE)

test_that("set_opts in a http request", {
  set_opts(timeout_ms = 1)
  expect_error(
    HttpClient$new(hb())$get('get')
  )
})


test_that("fails well", {
  skip_on_cran()

  expect_error(set_auth(), "argument \"x\" is missing")
  expect_error(set_proxy(), "argument \"x\" is missing")
})

#reset
crul_settings(reset = TRUE)


test_that("set_auth works", {
  expect_type(set_auth, "closure")

  # without it set
  aa <- crul_settings()
  expect_length(aa, 0)

  # set it
  set_auth(auth(user = "foo", pwd = "bar", auth = "basic"))

  # after set_auth set
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("crul_auth"))
  expect_named(get("crul_auth", envir = crul_opts), c("userpwd", "httpauth"))
  expect_equal(get("crul_auth", envir = crul_opts)$userpwd, "foo:bar")
  expect_equal(get("crul_auth", envir = crul_opts)$httpauth, 1)
})
#reset
crul_settings(reset = TRUE)


test_that("set_headers works", {
  expect_type(set_headers, "closure")

  # without it set
  aa <- crul_settings()
  expect_length(aa, 0)

  # set it
  set_headers(foo = "bar")
  set_headers(`User-Agent` = "hello world")

  # after set_auth set
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("headers"))
  expect_named(get("headers", envir = crul_opts), c("foo", "User-Agent"))
  expect_equal(get("headers", envir = crul_opts)$foo, "bar")
  expect_equal(get("headers", envir = crul_opts)$`User-Agent`, "hello world")
})
#reset
crul_settings(reset = TRUE)


test_that("set_proxy works", {
  expect_type(set_proxy, "closure")

  # without it set
  aa <- crul_settings()
  expect_length(aa, 0)

  # set it
  set_proxy(proxy("http://97.77.104.22:3128"))

  # after set_auth set
  aa <- crul_settings()
  expect_length(aa, 1)
  expect_equal(unlist(as.list(aa)), c("proxies"))
  expect_s3_class(get("proxies", envir = crul_opts), "proxy")
  expect_named(
    get("proxies", envir = crul_opts),
    c("proxy", "proxyport", "proxyauth")
  )
  expect_equal(get("proxies", envir = crul_opts)$proxy, "97.77.104.22")
  expect_equal(get("proxies", envir = crul_opts)$proxyport, 3128)
  expect_equal(get("proxies", envir = crul_opts)$proxyauth, 1)
})
#reset
crul_settings(reset = TRUE)
