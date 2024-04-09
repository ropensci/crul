skip_if_offline(url_parse(hb())$domain)

context("user-agent")

test_that("user-agent internal helper fxn works as expected", {
  skip_on_cran()

  aa <- make_ua()

  expect_is(aa, "character")
  expect_match(aa, 'libcurl')
  expect_match(aa, 'r-curl')
  expect_match(aa, 'crul')
})


test_that("user-agent: default behavior", {
  skip_on_cran()

  cli <- HttpClient$new(url = hb())
  res_get <- cli$get("get")
  res_head <- cli$head("get")
  res_post <- cli$post("post")

  expect_is(cli, "HttpClient")
  expect_equal(length(cli$headers), 0)
  expect_equal(length(cli$opts), 0)
  expect_equal(res_get$request_headers$`User-Agent`, make_ua()) 
  expect_equal(res_head$request_headers$`User-Agent`, make_ua()) 
  expect_equal(res_post$request_headers$`User-Agent`, make_ua()) 
})

test_that("user-agent: passed as option", {
  skip_on_cran()

  cli <- HttpClient$new(url = hb(), 
    opts = list(useragent = "hello world"))
  res_get <- cli$get("get")
  res_head <- cli$head("get")
  res_post <- cli$post("post")

  expect_is(cli, "HttpClient")
  expect_equal(length(cli$headers), 0)
  expect_named(cli$opts, "useragent")
  expect_equal(res_get$request_headers$`User-Agent`, "hello world") 
  expect_equal(res_head$request_headers$`User-Agent`, "hello world") 
  expect_equal(res_post$request_headers$`User-Agent`, "hello world") 
})

test_that("user-agent: passed as header", {
  skip_on_cran()

  cli <- HttpClient$new(url = hb(), 
    headers = list(`User-Agent` = "hello world")
  )
  res_get <- cli$get("get")
  res_head <- cli$head("get")
  res_post <- cli$post("post")

  expect_is(cli, "HttpClient")
  expect_equal(length(cli$opts), 0)
  expect_named(cli$headers, "User-Agent")
  expect_equal(res_get$request_headers$`User-Agent`, "hello world") 
  expect_equal(res_head$request_headers$`User-Agent`, "hello world") 
  expect_equal(res_post$request_headers$`User-Agent`, "hello world") 
})
