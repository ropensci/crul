skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

context("mocking: mock function")
test_that("crul_opts env", {
  expect_is(crul_opts, "environment")
  expect_false(crul_opts$mock)
})

test_that("mock function", {
  expect_is(mock, "function")
  expect_true(mock())
  expect_true(crul_opts$mock)
  expect_false(mock(FALSE))
  expect_false(crul_opts$mock)
})

context("mocking: HttpRequest with AsyncVaried")
test_that("mocking with HttpRequest", {
  skip_if_not_installed("webmockr")

  loadNamespace("webmockr")
  url <- hb()
  st <- webmockr::stub_request("get", file.path(url, "get"))
  #webmockr:::webmockr_stub_registry

  make_req <- function(url) {
    req <- HttpRequest$new(url = url)
    req$get("get")
    res <- AsyncVaried$new(req)
    res$request()
    return(unclass(res$responses())[[1]])
  }

  mock(FALSE)
  # webmockr IS NOT enabled
  aa <- make_req(url)

  # webmockr IS enabled
  mock()
  bb <- make_req(url)

  # content and times differ btw the two
  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(bb, "HttpResponse")

  expect_is(aa$content, "raw")
  expect_equal(length(bb$content), 0)

  expect_is(aa$times, "numeric")
  expect_null(bb$times)

  # clean up
  webmockr::stub_registry_clear()
})

context("mocking: HttpRequest with Async")
test_that("mocking with HttpRequest", {
  skip_if_not_installed("webmockr")

  loadNamespace("webmockr")
  url <- hb()
  urls <- c(
    file.path(url, "get"),
    file.path(url, "anything"),
    file.path(url, "encoding/utf8")
  )
  for (u in urls) webmockr::stub_request("get", u)
  # webmockr::stub_registry()

  make_req <- function(urls) {
    cc <- Async$new(urls = urls)
    cc$get()
  }

  mock(FALSE)
  # webmockr IS NOT enabled
  not_mocked <- make_req(urls)

  # webmockr IS enabled
  mock()
  mocked <- make_req(urls)

  expect_s3_class(not_mocked[[1]], "HttpResponse")
  expect_s3_class(mocked[[1]], "HttpResponse")

  expect_s3_class(not_mocked[[1]]$status_http(), "http_code")
  expect_s3_class(mocked[[1]]$status_http(), "http_code")

  expect_is(not_mocked[[1]]$content, "raw")
  expect_equal(length(mocked[[1]]$content), 0)

  expect_is(not_mocked[[1]]$times, "numeric")
  expect_null(mocked[[1]]$times)

  # clean up
  webmockr::stub_registry_clear()
})

context("mocking: HttpClient")
test_that("mocking with HttpClient", {
  skip_if_not_installed("webmockr")

  loadNamespace("webmockr")
  url <- hb()
  st <- webmockr::stub_request("get", file.path(url, "get"))
  #webmockr:::webmockr_stub_registry

  mock(FALSE)
  # webmockr IS NOT enabled
  cli <- HttpClient$new(url = url)
  aa <- cli$get("get")

  # webmockr IS enabled
  mock()
  bb <- cli$get("get")

  # content and times differ btw the two
  expect_is(aa, "HttpResponse")
  expect_is(bb, "HttpResponse")

  expect_is(aa$content, "raw")
  expect_equal(length(bb$content), 0)

  expect_is(aa$times, "numeric")
  expect_null(bb$times)

  # clean up
  webmockr::stub_registry_clear()
})

context("mocking: HttpClient when not stubbed yet")
test_that("mocking with HttpClient: ", {
  skip_if_not_installed("webmockr")

  loadNamespace("webmockr")
  url <- hb()
  st <- webmockr::stub_request("get", file.path(url, "get"))
  #webmockr:::webmockr_stub_registry

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
  webmockr::stub_registry_clear()
})

# turn mocking off
mock(FALSE)
