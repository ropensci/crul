all: move rmd2md

move:
		cp inst/vign/crul_vignette.md vignettes;\
		cp inst/vign/how-to-use-crul.md vignettes;\
		cp inst/vign/async.md vignettes;\
		cp inst/vign/curl-options.md vignettes

rmd2md:
		cd vignettes;\
		mv crul_vignette.md crul_vignette.Rmd;\
		mv how-to-use-crul.md how-to-use-crul.Rmd;\
		mv async.md async.Rmd;\
		mv curl-options.md curl-options.Rmd
