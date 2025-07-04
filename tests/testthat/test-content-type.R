skip_on_cran()
skip_if_offline(url_parse(hb())$domain)

res_html <- HttpClient$new(url = hb("/html"))$get()
res_json <- HttpClient$new(url = hb())$get('/get')
res_xml <- HttpClient$new(url = hb("/xml"))$get()

test_that("html", {
  ## get the content type
  expect_match(
    res_html$response_headers$`content-type`,
    "text/html; charset=utf-8"
  )

  ## check that the content type is text/html
  expect_null(res_html$raise_for_ct_html())

  ## it's def. not json or xml
  expect_error(res_html$raise_for_ct_json(), "did not match")
  expect_error(res_html$raise_for_ct_xml(), "did not match")
  ### behavior: warning
  expect_warning(
    res_html$raise_for_ct_json(behavior = "warning"),
    "did not match"
  )

  ## give custom content type
  expect_null(res_html$raise_for_ct("text/html"))
  expect_error(res_html$raise_for_ct("application/json"), "did not match")
  ### behavior: warning
  expect_warning(
    res_html$raise_for_ct("application/json", behavior = "warning"),
    "did not match"
  )
  expect_error(res_html$raise_for_ct("foo/bar"), "type not in allowed set")
})

test_that("json", {
  ## get the content type
  expect_match(res_json$response_headers$`content-type`, "application/json")

  ## check that the content type is text/html
  expect_null(res_json$raise_for_ct_json())

  ## it's def. not xml
  expect_error(res_json$raise_for_ct_xml(), "did not match")
  ### behavior: warning
  expect_warning(
    res_json$raise_for_ct_xml(behavior = "warning"),
    "did not match"
  )

  ## give custom content type
  expect_null(res_json$raise_for_ct("application/json"))
  expect_error(res_json$raise_for_ct("application/xml"), "did not match")
  ### behavior: warning
  expect_warning(
    res_json$raise_for_ct("application/xml", behavior = "warning"),
    "did not match"
  )
})

test_that("xml", {
  ## get the content type
  expect_match(res_xml$response_headers$`content-type`, "application/xml")

  ## check that the content type is text/html
  expect_null(res_xml$raise_for_ct_xml())

  ## it's def. not json
  expect_error(res_xml$raise_for_ct_json(), "did not match")
  ### behavior: warning
  expect_warning(
    res_xml$raise_for_ct_json(behavior = "warning"),
    "did not match"
  )

  ## give custom content type
  expect_null(res_xml$raise_for_ct("application/xml"))
  expect_error(res_xml$raise_for_ct("application/json"), "did not match")
  ### behavior: warning
  expect_warning(
    res_xml$raise_for_ct("application/json", behavior = "warning"),
    "did not match"
  )
  expect_error(res_xml$raise_for_ct("foo/bar"), "type not in allowed set")
})


test_that("charset works", {
  ## check charset in addition to the media type

  ### warning thrown that no charset detected - don't want to fail if no charset given by server
  expect_warning(
    res_json$raise_for_ct_json(charset = "utf-8"),
    "no charset detected"
  )

  ### charset should be given with text/html response
  #### nothing happens if a match
  expect_null(res_html$raise_for_ct_html(charset = "utf-8"))
  #### error if not matched
  expect_error(res_html$raise_for_ct_html(charset = "utf-16"), "did not match")

  ### w/ custom type
  expect_null(res_html$raise_for_ct("text/html", charset = "utf-8"))
  expect_error(
    res_html$raise_for_ct("text/html", charset = "utf-16"),
    "did not match"
  )
})
