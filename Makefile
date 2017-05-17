all: move rmd2md

move:
		cp inst/vign/crul_vignette.md vignettes;\
		cp inst/vign/async.md vignettes;\
		cp inst/vign/how-to-use-crul.md vignettes

rmd2md:
		cd vignettes;\
		mv crul_vignette.md crul_vignette.Rmd;\
		mv async.md async.Rmd;\
		mv how-to-use-crul.md how-to-use-crul.Rmd
