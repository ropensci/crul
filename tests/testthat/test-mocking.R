skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

test_that("mock function", {
  withr::local_options(lifecycle_verbosity = "quiet")

  expect_type(mock, "closure")
  expect_null(mock())
  expect_null(mock(FALSE))
  expect_false("mock" %in% names(crul_opts))
})

test_that("mocking with HttpRequest", {
  skip_if_not_installed("webmockr")

  library(webmockr)
  withr::defer({
    if ("webmockr" %in% loadedNamespaces()) {
      try(disable(quiet = TRUE), silent = TRUE)
      try(stub_registry_clear(), silent = TRUE)
      unloadNamespace("webmockr")
    }
  })
  url <- hb()
  st <- stub_request("get", file.path(url, "get"))

  make_req <- function(url) {
    req <- HttpRequest$new(url = url)
    req$get("get")
    res <- AsyncVaried$new(req)
    res$request()
    return(unclass(res$responses())[[1]])
  }

  # webmockr IS NOT enabled
  aa <- make_req(url)

  # webmockr IS enabled
  enable(quiet = TRUE)
  withr::defer(disable(quiet = TRUE))
  bb <- make_req(url)

  # content and times differ btw the two
  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(bb, "HttpResponse")

  expect_type(aa$content, "raw")
  expect_equal(length(bb$content), 0)

  expect_type(aa$times, "double")
  expect_null(bb$times)

  # clean up
  stub_registry_clear()
})

test_that("mocking with HttpRequest & webmockr", {
  skip_if_not_installed("webmockr")

  library(webmockr)
  withr::defer({
    if ("webmockr" %in% loadedNamespaces()) {
      try(disable(quiet = TRUE), silent = TRUE)
      try(stub_registry_clear(), silent = TRUE)
      unloadNamespace("webmockr")
    }
  })
  url <- hb()
  urls <- c(
    file.path(url, "get"),
    file.path(url, "anything"),
    file.path(url, "encoding/utf8")
  )
  for (u in urls) {
    stub_request("get", u)
  }

  make_req <- function(urls) {
    cc <- Async$new(urls = urls)
    cc$get()
  }

  # webmockr IS NOT enabled
  not_mocked <- make_req(urls)

  # webmockr IS enabled
  enable(quiet = TRUE)
  withr::defer(disable(quiet = TRUE))
  mocked <- make_req(urls)

  expect_s3_class(not_mocked[[1]], "HttpResponse")
  expect_s3_class(mocked[[1]], "HttpResponse")

  expect_s3_class(not_mocked[[1]]$status_http(), "http_code")
  expect_s3_class(mocked[[1]]$status_http(), "http_code")

  expect_type(not_mocked[[1]]$content, "raw")
  expect_equal(length(mocked[[1]]$content), 0)

  expect_type(not_mocked[[1]]$times, "double")
  expect_null(mocked[[1]]$times)

  # clean up
  stub_registry_clear()
})

test_that("mocking with HttpRequest w/o webmockr", {
  url <- hb()
  urls <- c(
    file.path(url, "get"),
    file.path(url, "anything"),
    file.path(url, "encoding/utf8")
  )

  make_req <- function(urls) {
    cc <- Async$new(urls = urls)
    cc$get(mock = \(req) {
      HttpResponse$new(
        method = "get",
        url = "https://hb.opencpu.org",
        content = charToRaw("hello world"),
        status_code = 200L
      )
    })
  }

  mocked <- make_req(urls)

  expect_s3_class(mocked[[1]], "HttpResponse")
  expect_s3_class(mocked[[1]]$status_http(), "http_code")
  expect_equal(mocked[[1]]$parse("UTF-8"), "hello world")
  expect_null(mocked[[1]]$times)
})

test_that("mocking with HttpClient w/o webmockr", {
  cli_no_mock <- HttpClient$new(url = hb())
  cli_no_mock_res <- cli_no_mock$get("get")

  cli_mocked <- HttpClient$new(url = hb())
  cli_mocked_res <- cli_mocked$get("get", mock = \(req) 200L)

  # content and times differ btw the two
  expect_s3_class(cli_no_mock_res, "HttpResponse")
  expect_type(cli_mocked_res, "integer")

  expect_type(cli_no_mock_res$content, "raw")
  expect_equal(cli_mocked_res, 200L)

  expect_type(cli_no_mock_res$times, "double")
})

test_that("mocking with HttpClient and webmockr", {
  skip_if_not_installed("webmockr")

  library(webmockr)
  withr::defer({
    if ("webmockr" %in% loadedNamespaces()) {
      try(disable(quiet = TRUE), silent = TRUE)
      try(stub_registry_clear(), silent = TRUE)
      unloadNamespace("webmockr")
    }
  })
  enable(quiet = TRUE)
  url <- hb()
  st <- stub_request("get", file.path(url, "get"))

  cli <- HttpClient$new(url = url)
  aa <- cli$get("get")

  # content and times differ btw the two
  expect_s3_class(aa, "HttpResponse")
  expect_type(aa$content, "raw")
  expect_null(aa$times)

  # clean up
  stub_registry_clear()
})


test_that("mocking with HttpClient fails well", {
  skip_if_not_installed("webmockr")

  library(webmockr)
  withr::defer({
    if ("webmockr" %in% loadedNamespaces()) {
      try(disable(quiet = TRUE), silent = TRUE)
      try(stub_registry_clear(), silent = TRUE)
      unloadNamespace("webmockr")
    }
  })
  enable(quiet = TRUE)
  url <- hb()
  st <- stub_request("get", file.path(url, "get"))

  # webmockr IS NOT enabled
  cli <- HttpClient$new(url = url)
  expect_error(
    cli$post("post"),
    "Real HTTP connections are disabled"
  )
  expect_error(
    cli$post("post"),
    "You can stub this request with the following snippet"
  )
  expect_error(
    cli$post("post"),
    "registered request stubs"
  )

  # clean up
  stub_registry_clear()
})
