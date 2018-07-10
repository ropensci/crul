crul_opts = NULL # nocov start

.onLoad <- function(libname, pkgname){
	crul_opts <<- new.env()
	crul_opts$mock <<- FALSE
} # nocov end
