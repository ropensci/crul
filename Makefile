PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all: move rmd2md

move:
		cp inst/vign/crul.md vignettes;\
		cp inst/vign/how-to-use-crul.md vignettes;\
		cp inst/vign/async.md vignettes;\
		cp inst/vign/curl-options.md vignettes

rmd2md:
		cd vignettes;\
		mv crul.md crul.Rmd;\
		mv how-to-use-crul.md how-to-use-crul.Rmd;\
		mv async.md async.Rmd;\
		mv curl-options.md curl-options.Rmd

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples(run = TRUE)"

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
