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
	${RSCRIPT} -e "devtools::run_examples()"

check:
	${RSCRIPT} -e "devtools::check(document = FALSE, cran = TRUE)"

test:
	${RSCRIPT} -e "devtools::test()"
