context("HttpResponse")

test_that("HttpResponse works", {
  expect_is(HttpResponse, "R6ClassGenerator")

  aa <- HttpResponse$new(
    method = "get",
    url = hb(),
    status_code = 201,
    request_headers = list(useragent = "foo bar"),
    content = charToRaw("hello world"),
    request = list()
  )

  expect_is(aa, "HttpResponse")
  expect_null(aa$handle)
  expect_null(aa$opts)
  expect_is(aa$url, "character")
  expect_is(aa$method, "character")
  expect_is(aa$content, "raw")
  expect_null(aa$modified)
  expect_is(aa$parse, "function")
  expect_is(aa$raise_for_status, "function")
  expect_is(aa$request_headers, "list")
  expect_null(aa$response_headers)
  expect_null(aa$response_headers_all)
  expect_equal(aa$status_code, 201)
  expect_is(aa$status_http, "function")
  expect_is(aa$success, "function")
  expect_true(aa$success())
  expect_null(aa$times)
  expect_is(aa$request, "list")


  aa <- HttpResponse$new(
    method = "get",
    url = hb(),
    status_code = 404,
    request_headers = list(useragent = "foo bar"),
    content = charToRaw("hello world"),
    request = list()
  )

  expect_error(aa$raise_for_status(), "Not Found \\(HTTP 404\\)",
    class = "error")
})

test_that("HttpResponse print method", {
  skip_on_cran()
  
  aa <- HttpResponse$new(
    method = "get",
    url = hb("/stuff?g=6"),
    status_code = 201,
    request_headers = list(useragent = "foo bar"),
    response_headers = list(`content-type` = "application/json"),
    content = charToRaw("hello world"),
    request = list()
  )

  expect_is(aa, "HttpResponse")
  expect_is(aa$print, "function")
  expect_output(aa$print(), "crul response")
  expect_output(aa$print(), "url:")
  expect_output(aa$print(), "request_headers:")
  expect_output(aa$print(), 'useragent')
  expect_output(aa$print(), "response_headers:")
  expect_output(aa$print(), 'content-type')
  expect_output(aa$print(), 'params')
  expect_output(aa$print(), 'g: 6')
  expect_output(aa$print(), 'status: 201')
})

test_that("HttpResponse fails well", {
  expect_error(HttpResponse$new(), "argument \"url\" is missing")
})

test_that("parse method", {
  aa <- HttpResponse$new(
    method = "get",
    url = hb(),
    status_code = 201,
    request_headers = list(useragent = "foo bar"),
    content = charToRaw("hello J\xf6reskog"),
    request = list()
  )

  # has correct parameters
  expect_named(formals(aa$parse), c("encoding", "..."))

  # can pass parameters to iconv
  expect_is(suppressMessages(aa$parse(sub = "")), "character")
  expect_true(nzchar(suppressMessages(aa$parse(sub = ""))))

  # sub parameter works
  expect_true(is.na(suppressMessages(aa$parse())))
  expect_match(suppressMessages(aa$parse(sub = "---")), "---")

  # toRaw parameter works
  expect_null(suppressMessages(aa$parse(toRaw = TRUE)[[1]]))
  expect_is(suppressMessages(aa$parse(sub = "", toRaw = TRUE)[[1]]), "raw")
})

test_that("parse works when file on disk is binary", {
  url <- "https://dods.ndbc.noaa.gov/thredds/fileServer/data/cwind/41001/41001c1997.nc"
  f <- "../fixtures/41001c1990.nc"
  # f <- file.path(tempdir(), "41001c1990.nc")
  # out <- HttpClient$new(url)$get(disk = f)

  opts <- list(
    url = handle(url),
    method = "get",
    options = list(httpget = TRUE, 
      useragent = "libcurl/7.54.0 r-curl/4.0 crul/0.8.1.9123"),
    headers = list(`Accept-Encoding` = "gzip, deflate", 
      Accept = "application/json, text/xml, application/xml, */*"),
    disk = f
  )

  aa <- HttpResponse$new(
    method = "get",
    url = url,
    status_code = 200,
    request_headers = opts$headers,
    content = f,
    handle = opts$url$handle,
    request = opts
  )

  # data is in the file
  expect_is(aa$content, "character")
  expect_equal(aa$content, f)
  expect_is(readLines(aa$content, n = 1, warn = FALSE), "character")

  # parse works on the binary content
  parsed <- aa$parse()
  expect_is(parsed, "raw")
  # binfile <- tempfile()
  # writeBin(parsed, con = file(binfile, open = "wb"))
  # on.exit(close(binfile))
  # file.info(binfile)
  # file.info(f)
})

test_that("internal fxn: parse_params", {
  url <- sprintf("%s/get?a=5&foo=bar", hb())
  x <- parse_params(url)

  expect_is(x, "character")
  expect_equal(length(x), 2)

  expect_null(parse_params(5))
  expect_error(parse_params(mtcars))
})

test_that("internal fxn: check_encoding", {
  x <- check_encoding("UTF-8")

  expect_is(x, "character")
  expect_equal(length(x), 1)

  # throws message about invalid encoding
  expect_message(check_encoding(5), "Invalid encoding 5")
  # and gives back utf-8
  expect_equal(suppressMessages(check_encoding(5)), "UTF-8")

  # needs input
  expect_error(check_encoding(), "argument \"x\" is missing")
})

# test_that("parse works for ftp text responses", {
#   url <- "ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt"
#   cli <- HttpClient$new(url = url)
#   aa <- cli$get()
#   txt <- aa$parse("UTF-8")

#   x <- aa$content
#   z <- readBin(x, character())
#   out <- iconv(z, from = guess_encoding(), to = "UTF-8", sub = "")


#   iconv(readBin(x, character()),
#     from = guess_encoding(encoding), to = "UTF-8")
# })
