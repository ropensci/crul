skip_on_cran()
skip_if_offline(url_parse(hb())$domain)


test_that("post request works", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$post("post")

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "post")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  expect_null(aa$request$fields)
})

test_that("post request with body", {
  cli <- HttpClient$new(url = hb())
  aa <- cli$post("post", body = list(hello = "world"))

  expect_s3_class(aa, "HttpResponse")
  expect_s3_class(aa$handle, 'curl_handle')
  expect_type(aa$content, "raw")
  expect_type(aa$method, "character")
  expect_equal(aa$method, "post")
  expect_type(aa$parse, "closure")
  expect_type(aa$parse(), "character")
  expect_true(aa$success())

  expect_named(aa$request$fields, "hello")
  expect_equal(aa$request$fields[[1]], "world")
})

body <- list(
  custname = 'Jane',
  custtel = '444-4444',
  custemail = 'stuff@things.com',
  size = 'small',
  topping = 'bacon',
  comments = 'make it snappy'
)

test_that("post request: encode=form", {
  cli <- HttpClient$new(url = hb("/post"))
  form <- cli$post(body = body, encode = "form")

  expect_s3_class(form, "HttpResponse")
  expect_equal(form$method, "post")
  expect_match(
    jsonlite::fromJSON(form$parse("UTF-8"))$headers$`Content-Type`,
    "application/x-www-form-urlencoded"
  )

  expect_null(form$request$fields)
  expect_true(form$request$options$post)
  expect_type(form$request$options$postfieldsize, "integer")
  expect_type(form$request$options$postfields, "raw")
})

test_that("post request: encode=multipart", {
  cli <- HttpClient$new(url = hb("/post"))
  multi <- cli$post(body = body, encode = "multipart")

  expect_s3_class(multi, "HttpResponse")
  expect_equal(multi$method, "post")
  expect_match(
    jsonlite::fromJSON(multi$parse("UTF-8"))$headers$`Content-Type`,
    "multipart/form-data"
  )

  expect_type(multi$request$fields, "list")
  expect_type(multi$request$fields$custname, "character")
  expect_type(multi$request$fields$size, "character")

  expect_true(multi$request$options$post)
  expect_null(multi$request$options$postfieldsize, "integer")
  expect_null(multi$request$options$postfields, "raw")
})

test_that("post request: encode=form/multipart both use form content-type when 0 length list", {
  cli <- HttpClient$new(url = hb("/post"))
  form <- cli$post(body = list(), encode = "form")
  multi <- cli$post(body = list(), encode = "multipart")

  expect_match(
    jsonlite::fromJSON(form$parse("UTF-8"))$headers$`Content-Type`,
    "application/x-www-form-urlencoded"
  )
  expect_match(
    jsonlite::fromJSON(multi$parse("UTF-8"))$headers$`Content-Type`,
    "application/x-www-form-urlencoded"
  )
})

test_that("post request: encode=form/multipart drop NULL elements in a list", {
  cli <- HttpClient$new(url = hb("/post"))
  form <- cli$post(body = list(a = 5, b = NULL), encode = "form")
  multi <- cli$post(body = list(a = 5, b = NULL), encode = "multipart")

  expect_equal(jsonlite::fromJSON(form$parse("UTF-8"))$form, list(a = "5"))
  expect_equal(jsonlite::fromJSON(multi$parse("UTF-8"))$form, list(a = "5"))
})


test_that("post request with file upload", {
  # txt file
  ## as file
  file <- upload(system.file("CITATION"))
  cli <- HttpClient$new(url = hb())
  aa <- cli$post("post", body = list(a = file))

  expect_s3_class(aa, "HttpResponse")
  expect_type(aa$content, "raw")
  expect_null(aa$request$options$readfunction)
  out <- jsonlite::fromJSON(aa$parse("UTF-8"))
  expect_named(out$files, "a")
  expect_match(out$files$a, "bibentry")

  ## as data
  aa2 <- cli$post("post", body = file)
  expect_s3_class(aa2, "HttpResponse")
  expect_type(aa2$content, "raw")
  expect_type(aa2$request$options$readfunction, "closure")
  out <- jsonlite::fromJSON(aa2$parse("UTF-8"))
  expect_equal(length(out$files), 0)
  expect_type(out$data, "character")
  expect_match(out$data, "bibentry")

  # binary file: jpeg
  file <- upload(file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg"))
  cli <- HttpClient$new(url = hb())
  aa <- cli$post("post", body = list(a = file))

  expect_s3_class(aa, "HttpResponse")
  expect_type(aa$content, "raw")
  expect_named(aa$request$fields, "a")
  out <- jsonlite::fromJSON(aa$parse("UTF-8"))
  expect_named(out$files, "a")
  expect_match(out$files$a, "data:image/jpeg")
})
