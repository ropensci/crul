PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

vigns: vign vign_how_to_use_crul vign_choosing_a_client vign_async vign_curl_options vign_best_practices

vign:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('crul.Rmd.og', output = 'crul.Rmd')";\
	cd ..

vign_how_to_use_crul:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('how-to-use-crul.Rmd.og', output = 'how-to-use-crul.Rmd')";\
	cd ..

vign_choosing_a_client:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('choosing-a-client.Rmd.og', output = 'choosing-a-client.Rmd')";\
	cd ..

vign_async:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('async.Rmd.og', output = 'async.Rmd')";\
	cd ..

vign_curl_options:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('curl-options.Rmd.og', output = 'curl-options.Rmd')";\
	cd ..

vign_best_practices:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('best-practices-api-packages.Rmd.og', output = 'best-practices-api-packages.Rmd')";\
	cd ..

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples(run_dontrun = TRUE)"

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD CHECK --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

test:
	${RSCRIPT} -e "devtools::test()"

check_windows:
	${RSCRIPT} -e "devtools::check_win_devel(); devtools::check_win_release()"

readme:
	${RSCRIPT} -e "knitr::knit('README.Rmd')"
