
test_that("retry works if success then failure", {
  skip_on_cran()
  skip_if_not_installed("webmockr")
  skip_if_not_installed("magrittr")

  loadNamespace("webmockr")
  webmockr::enable()
  cli <- HttpClient$new(url = "http://bla.blop")

  stub <- webmockr::stub_request("get", "http://bla.blop")
  stub %>%
    webmockr::to_return(status = 503) %>%
    webmockr::to_return(status = 200, body = "{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"application/json,
        text/xml, application/xml, */*\", \n    \"Accept-Encoding\": \"gzip, deflate\",
        \n    \"Connection\": \"close\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\":
        \"libcurl/7.54.0 r-curl/3.2 crul/0.5.2\"\n  }, \n  \"origin\": \"111.222.333.444\",
        \n  \"url\": \"https://eu.httpbin.org/get\"\n}\n", headers = list(b = 6))
  expect_message(thing <- cli$retry("get", onwait = function(resp, secs) {message("retry message")}), "retry message")
    expect_equal(thing$status_code, 200)


})
