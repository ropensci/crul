context("request: post")

test_that("post request works", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$post("post")

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "post")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("post request with body", {
  skip_on_cran()

  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$post("post", body = list(hello = "world"))

  expect_is(aa, "HttpResponse")
  expect_is(aa$handle, 'curl_handle')
  expect_is(aa$content, "raw")
  expect_is(aa$method, "character")
  expect_equal(aa$method, "post")
  expect_is(aa$parse, "function")
  expect_is(aa$parse(), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})


test_that("post request with file upload", {
  skip_on_cran()

  # txt file
  ## as file
  file <- upload(system.file("CITATION"))
  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$post("post", body = list(a = file))

  expect_is(aa, "HttpResponse")
  expect_is(aa$content, "raw")
  expect_null(aa$request$options$readfunction)
  out <- jsonlite::fromJSON(aa$parse("UTF-8"))
  expect_named(out$files, "a")
  expect_match(out$files$a, "bibentry")

  ## as data
  aa2 <- cli$post("post", body = file)
  expect_is(aa2, "HttpResponse")
  expect_is(aa2$content, "raw")
  expect_is(aa2$request$options$readfunction, "function")
  out <- jsonlite::fromJSON(aa2$parse("UTF-8"))
  expect_equal(length(out$files), 0)
  expect_is(out$data, "character")
  expect_match(out$data, "bibentry")


  # binary file: jpeg
  file <- upload(file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg"))
  cli <- HttpClient$new(url = "https://httpbin.org")
  aa <- cli$post("post", body = list(a = file))

  expect_is(aa, "HttpResponse")
  expect_is(aa$content, "raw")
  expect_named(aa$request$fields, "a")
  out <- jsonlite::fromJSON(aa$parse("UTF-8"))
  expect_named(out$files, "a")
  expect_match(out$files$a, "data:image/jpeg")
})
