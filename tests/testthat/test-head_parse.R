headers <- list(
  good = list(
    httpbin = "HTTP/2 200 \r\ncache-control: public, max-age=0, must-revalidate\r\ncontent-type: text/html; charset=UTF-8\r\ndate: Tue, 01 Dec 2020 15:56:06 GMT\r\netag: \"ce90a0bea2e4316f8073de05498b3b91-ssl-df\"\r\nstrict-transport-security: max-age=31536000\r\ncontent-encoding: gzip\r\ncontent-length: 2358\r\nage: 9137\r\nserver: Netlify\r\nvary: Accept-Encoding\r\nx-nf-request-id: 93faf14b-0a64-4f8b-a2c1-5007ccd8b987-95882528\r\n\r\n",
    nytimes = "HTTP/2 200 \r\nserver: nginx\r\ncontent-type: text/html; charset=utf-8\r\nx-nyt-data-last-modified: Tue, 01 Dec 2020 18:29:33 GMT\r\nlast-modified: Tue, 01 Dec 2020 18:29:33 GMT\r\nx-pagetype: vi-homepage\r\nx-xss-protection: 1; mode=block\r\nx-content-type-options: nosniff\r\ncontent-encoding: gzip\r\ncache-control: s-maxage=30,no-cache\r\nx-nyt-route: homepage\r\nx-origin-time: 2020-12-01 18:29:35 UTC\r\naccept-ranges: bytes\r\ndate: Tue, 01 Dec 2020 18:30:31 GMT\r\nage: 25\r\nx-served-by: cache-lga21959-LGA, cache-sjc10075-SJC\r\nx-cache: HIT, HIT\r\nx-cache-hits: 1, 49\r\nx-timer: S1606847431.178516,VS0,VE1\r\nvary: Accept-Encoding, Fastly-SSL\r\nset-cookie: nyt-a=fFm7d0XINOn9L3e2cuzBbb; Expires=Wed, 01 Dec 2021 18:30:31 GMT; Path=/; Domain=.nytimes.com; SameSite=none; Secure\r\nset-cookie: nyt-gdpr=0; Expires=Wed, 02 Dec 2020 00:30:31 GMT; Path=/; Domain=.nytimes.com\r\nx-gdpr: 0\r\nset-cookie: nyt-purr=cfhhcfhhhck; Expires=Wed, 01 Dec 2021 18:30:31 GMT; Path=/; Domain=.nytimes.com; SameSite=Lax; Secure\r\nset-cookie: nyt-geo=US; Expires=Wed, 02 Dec 2020 00:30:31 GMT; Path=/; Domain=.nytimes.com\r\nx-frame-options: DENY\r\nonion-location: https://www.nytimes3xbfgragh.onion/\r\nx-api-version: F-F-VI\r\ncontent-security-policy: upgrade-insecure-requests; default-src data: 'unsafe-inline' 'unsafe-eval' https:; script-src data: 'unsafe-inline' 'unsafe-eval' https: blob:; style-src data: 'unsafe-inline' https:; img-src data: https: blob:; font-src data: https:; connect-src https: wss: blob:; media-src data: https: blob:; object-src https:; child-src https: data: blob:; form-action https:; report-uri https://csp.nytimes.com/report;\r\nstrict-transport-security: max-age=63072000; preload\r\ncontent-length: 162223\r\n\r\n"
  ),
  bad = list(
    open.canada.ca = "HTTP/1.1 200 OK\r\nServer: nginx\r\nDate: Tue, 01 Dec 2020 18:27:59 GMT\r\nContent-Type: application/json;charset=utf-8\r\nContent-Length: 460\r\nConnection: keep-alive\r\nKeep-Alive: timeout=5\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nAccess-Control-Allow-Origin: *\r\nX-Frame-Options: ALLOW-FROM open.canada.ca ouvert.canada.ca\r\nContent-Security-Policy: frame-ancestors https://open.canada.ca https://ouvert.canada.ca\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 1; mode=block\r\nStrict-Transport-Security: max-age=31536000; includeSubDomains\r\nX-UA-Compatible: IE=Edge\r\nContent-Security-Policy: default-src 'self' 'unsafe-inline' *.affmunqc.net *.arcgis.com *.arcgisonline.com *.atlas.gouv.qc.ca *.canada.ca *.demdex.net *.education.gouv.qc.ca *.epsg.io *.gc.ca *.geo.ca maps.ducks.ca *.google-analytics.com *.googletagmanager.comi *.gouv.qc.ca *.gov.bc.ca *.maps.alberta.ca *.mapserver.transports.gouv.qc.ca *.mern.gouv.qc.ca *.mrnf.gouv.qc.ca *.msp.gouv.qc.ca *.omtrdc.net *.open.canada.ca *.rouyn-noranda.ca *.services.geo.ca *.servicesgeo.enviroweb.gouv.qc.ca *.shawinigan.ca *.sherbrooke.qc.ca *.ville.lac-megantic.qc.ca *.ville.montreal.qc.ca *.ville.quebec.qc.ca *.ville.sherbrooke.qc.ca ftp://*.gouv.qc.ca geodiscover.alberta.ca governmentofbc.maps.arcgis.com platform.twitter.com syndication.twitter.com www.youtube.com youtube.com;\n        script-src 'self' 'unsafe-inline' 'unsafe-eval' data: *.open.canada.ca *.canada.ca webservices.maps.canada.ca *.google-analytics.com ajax.googleapis.com js.arcgis.com *.gc.ca *.geosciences.ca *.epsg.io epsg.io www.youtube.com youtube.com s.ytimg.com platform.twitter.com *.syndication.twimg.com *.adobedtm.com *.omtrdc.net www.googletagmanager.com d3js.org cdnjs.cloudflare.com cdn.datatables.net cdn.jsdelivr.net cdn.polyfill.io code.jquery.com use.fontawesome.com *.foresee.com *.answerscloud.com *.foreseeresults.com *.4seeresults.com blob:;\n        img-src 'self' data: *.affmunqc.net *.arcgisonline.com *.atlas.gouv.qc.ca *.canada.ca *.demdex.net *.education.gouv.qc.ca *.epsg.io *.everesttech.net *.foresee.com *.gc.ca *.geo.ca *.geosciences.ca *.google-analytics.com *.gouv.qc.ca *.gov.bc.ca *.maps.alberta.ca *.google.ca *.google.com *.mapserver.transports.gouv.qc.ca *.mern.gouv.qc.ca *.mrnf.gouv.qc.ca *.msp.gouv.qc.ca *.nfis.org *.omtrdc.net *.open.canada.ca *.rouyn-noranda.ca *.services.geo.ca *.servicesgeo.enviroweb.gouv.qc.ca *.shawinigan.ca *.sherbrooke.qc.ca *.twimg.com *.ville.lac-megantic.qc.ca *.ville.montreal.qc.ca *.ville.quebec.qc.ca *.ville.sherbrooke.qc.ca cdn.datatables.net ftp://*.gouv.qc.ca geodiscover.alberta.ca governmentofbc.maps.arcgis.com http://geogratis.gc.ca http://*.geogratis.gc.ca http://*.affmunqc.net js.arcgis.com maps.ducks.ca platform.twitter.com syndication.twitter.com;\n        style-src 'self' 'unsafe-inline' maxcdn.bootstrapcdn.com netdna.bootstrapcdn.com *.gc.ca *.open.canada.ca *.canada.ca fonts.googleapis.com platform.twitter.com cdn.datatables.net cdn.jsdelivr.net use.fontawesome.com *.foresee.com;\n        font-src 'self' maxcdn.bootstrapcdn.com netdna.bootstrapcdn.com *.open.canada.ca *.canada.ca fonts.googleapis.com fonts.gstatic.com cdn.jsdelivr.net use.fontawesome.com *.foresee.com;\n        connect-src 'self' *.4seeresults.com *.affmunqc.net *.answerscloud.com *.arcgis.com *.arcgisonline.com *.atlas.gouv.qc.ca *.canada.ca *.education.gouv.qc.ca *.epsg.io epsg.io *.foresee.com *.foreseeresults.com *.gc.ca *.g.doubleclick.net *.geo.ca maps.ducks.ca *.geosciences.ca *.google-analytics.com *.gouv.qc.ca *.mapserver.transports.gouv.qc.ca *.mern.gouv.qc.ca *.mrnf.gouv.qc.ca *.msp.gouv.qc.ca *.omtrdc.net *.open.canada.ca *.rouyn-noranda.ca *.services.geo.ca *.servicesgeo.enviroweb.gouv.qc.ca *.shawinigan.ca *.sherbrooke.qc.ca *.ville.lac-megantic.qc.ca *.ville.montreal.qc.ca *.ville.quebec.qc.ca *.ville.sherbrooke.qc.ca dpm.demdex.net fonts.gstatic.com ftp://*.gouv.qc.ca;\n        object-src 'self' *.open.canada.ca *.canada.ca www.youtube.com youtube.com *.gc.ca;\n        media-src 'self' *.open.canada.ca *.canada.ca *.gc.ca www.youtube.com youtube.com epsg.io\r\nX-Pool: 3\r\n\r\n"
  )
)

test_that("head_parse: good", {
  # cat("-- good --", sep = "\n")
  for (i in seq_along(headers$good)) {
    # cat(paste0("  doing: ", names(headers$good)[i]), sep = "\n")
    z <- curl::parse_headers(headers$good[[i]], multiple = TRUE)
    zparsed <- lapply(z, head_parse)
    expect_type(zparsed, "list")
    expect_length(zparsed, 1)
    expect_named(zparsed[[1]])
    expect_equal(zparsed[[1]]$status, "HTTP/2 200")
    w <- unname(unlist(zparsed[[1]]))
    for (j in w) {
      expect_false(grepl("^\\s|\\s$", j))
    }
  }
})

test_that("head_parse: bad", {
  # cat("-- bad --", sep = "\n")
  for (i in seq_along(headers$bad)) {
    # cat(paste0("  doing: ", names(headers$bad)[i]), sep = "\n")
    z <- curl::parse_headers(headers$bad[[i]], multiple = TRUE)
    zparsed <- lapply(z, function(w) suppressWarnings(head_parse(w)))
    expect_type(zparsed, "list")
    expect_length(zparsed, 1)
    expect_named(zparsed[[1]])
    expect_equal(zparsed[[1]]$status, "HTTP/1.1 200 OK")
    w <- unname(unlist(zparsed[[1]]))
    for (j in w) {
      expect_false(grepl("^\\s|\\s$", j))
    }
    # should throw warnings for each bad header
    lapply(z, function(w) expect_warning(head_parse(w)))
  }
})
