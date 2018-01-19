context("Async - General")

test_that("Async works", {
  skip_on_cran()

  expect_is(Async, "R6ClassGenerator")

  aa <- Async$new(urls = c('https://httpbin.org/get', 'https://google.com'))

  expect_is(aa, "Async")
  expect_null(aa$handle)
  expect_is(aa$urls, "character")
  expect_equal(length(aa$urls), 2)
  expect_is(aa$.__enclos_env__$private$gen_interface, "function")

  expect_is(aa$get, "function")
  expect_is(aa$post, "function")
  expect_is(aa$put, "function")
  expect_is(aa$patch, "function")
  expect_is(aa$delete, "function")
  expect_is(aa$head, "function")

  # after calling
  res <- aa$get()
  expect_is(res, "list")
  expect_equal(length(res), 2)
  expect_is(res[[1]], "HttpResponse")
  expect_is(res[[1]]$request, "HttpRequest")
  expect_is(res[[1]]$content, "raw")
})

test_that("Async fails well", {
  skip_on_cran()

  expect_error(Async$new(), "\"urls\" is missing, with no default")
})



context("Async - get")
test_that("Async - get", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/get',
                           'https://google.com'))
  out <- aa$get()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_equal(out[[1]]$method, "get")
  expect_equal(out[[2]]$method, "get")
})


context("Async - post")
test_that("Async - post", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/post',
                           'https://httpbin.org/post'))
  out <- aa$post()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_equal(out[[1]]$method, "post")
})


context("Async - put")
test_that("Async - put", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/put',
                           'https://httpbin.org/put'))
  out <- aa$put()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_equal(out[[1]]$method, "put")
  expect_equal(out[[2]]$method, "put")
})


context("Async - patch")
test_that("Async - patch", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/patch',
                           'https://httpbin.org/patch'))
  out <- aa$patch()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_equal(out[[1]]$method, "patch")
  expect_equal(out[[2]]$method, "patch")
})


context("Async - delete")
test_that("Async - delete", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/delete',
                           'https://httpbin.org/delete'))
  out <- aa$delete()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_equal(out[[1]]$method, "delete")
  expect_equal(out[[2]]$method, "delete")
})


context("Async - head")
test_that("Async - head", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://google.com',
                           'https://nytimes.com'))
  out <- aa$head()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_equal(out[[1]]$method, "head")
  expect_equal(out[[2]]$method, "head")
})


context("Async - order of results")
test_that("Async - order", {
  skip_on_cran()

  aa <- Async$new(urls = c('https://httpbin.org/get?a=5',
                           'https://httpbin.org/get?b=6',
                           'https://httpbin.org/get?c=7'))
  out <- aa$get()

  expect_is(out, "list")
  expect_is(out[[1]], "HttpResponse")
  expect_is(out[[2]], "HttpResponse")
  expect_is(out[[3]], "HttpResponse")

  expect_match(out[[1]]$url, "a=5")
  expect_match(out[[2]]$url, "b=6")
  expect_match(out[[3]]$url, "c=7")
})

context("Async - disk")
test_that("Async - writing to disk works", {
  skip_on_cran()

  cc <- Async$new(
    urls = c(
      'https://httpbin.org/get?a=5',
      'https://httpbin.org/get?foo=bar',
      'https://httpbin.org/get?b=4',
      'https://httpbin.org/get?stuff=things',
      'https://httpbin.org/get?b=4&g=7&u=9&z=1'
    )
  )
  files <- replicate(5, tempfile())
  res <- cc$get(disk = files)
  out <- lapply(files, readLines)

  # cleanup
  closeAllConnections()

  expect_is(res, "list")
  expect_is(res[[1]], "HttpResponse")
  expect_is(out, "list")
  expect_is(out[[1]], "character")
})

context("Async - stream")
test_that("Async - streaming to disk works", {
  skip_on_cran()

  bb <- Async$new(urls = c('https://httpbin.org/get?a=5',
                           'https://httpbin.org/get?b=6',
                           'https://httpbin.org/get?c=7'))
  mylist <- c()
  fun <- function(x) mylist <<- c(mylist, x)
  out <- bb$get(stream = fun)

  expect_is(bb, "Async")

  expect_is(out[[1]], "HttpResponse")

  expect_identical(out[[1]]$content, raw(0))
  expect_identical(out[[2]]$content, raw(0))
  expect_identical(out[[3]]$content, raw(0))

  expect_is(mylist, "raw")
  expect_is(rawToChar(mylist), "character")
  expect_match(rawToChar(mylist), "application/json")
})
