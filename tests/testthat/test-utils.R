test_that("encode", {
  aa <- encode(hb())
  bb <- encode(I(hb()))

  expect_type(aa, "character")
  expect_s3_class(bb, "AsIs")

  expect_match(aa, "%3A")
  expect_false(grepl("%3A", bb))
})


test_that("has_name", {
  expect_false(has_name(5))
  expect_true(all(has_name(mtcars)))
  expect_true(has_name(list(a = 5)))
  expect_false(has_name(list(5)))
})


test_that("has_namez", {
  expect_false(has_namez(5))
  expect_true(has_namez(mtcars))
  expect_true(has_namez(list(a = 5)))
  expect_false(has_namez(list(5)))
})


test_that("make_query", {
  aa <- make_query(list(foo = "hello", bar = "world"))

  expect_type(aa, "character")
  expect_match(aa, "foo")
  expect_match(aa, "&")
  expect_match(aa, "=")
})


test_that("curl_opts_check works", {
  expect_null(curl_opts_check(verbose = TRUE))
  expect_null(curl_opts_check(timeout_ms = 0.001))
  expect_error(
    curl_opts_check(httppost = 1),
    "the following curl options are not allowed"
  )
})

test_that("num_format works", {
  expect_null(num_format(NULL))
  expect_equal(num_format(c("hello", "goodbye")), c("hello", "goodbye"))
  expect_equal(num_format(c(11, 0.00005, 200000)), c("11", "0.00005", "200000"))
})
