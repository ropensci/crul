context("mocking: mock function")
test_that("crul_opts env", {
  skip_on_cran()

  expect_is(crul_opts, "environment")
  expect_false(crul_opts$mock)
})

test_that("mock function", {
  skip_on_cran()

  expect_is(mock, "function")
  expect_true(mock())
  expect_true(crul_opts$mock)
  expect_false(mock(FALSE))
  expect_false(crul_opts$mock)
})

context("mocking: HttpClient")
test_that("mocking with HttpClient", {
  skip_on_cran()
  skip_if_not_installed("webmockr")

  loadNamespace("webmockr")
  url <- hb()
  st <- webmockr::stub_request("get", file.path(url, "get"))
  #webmockr:::webmockr_stub_registry

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
  skip_on_cran()
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
