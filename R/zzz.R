#set global variables
.onLoad <- function(libname, pkgname) {
    scattermore.globals <<- new.env()
    scattermore.globals$dim_RGBWT <- 5
    scattermore.globals$dim_RGBA <- 4
}