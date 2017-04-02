crul_opts = NULL

.onLoad <- function(libname, pkgname){
	crul_opts <<- new.env()
	crul_opts$mock <<- FALSE
}
