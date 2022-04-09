#' rgba_float_to_rgba_int
#'
#' Convert RGBA matrix to RGBA matrix.
#'
#' @param fRGBA RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @return RGBA matrix, output *is not premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgba_float_to_rgba_int <- function(fRGBA)
{
    if(!is.array(fRGBA) || dim(fRGBA)[3] != scattermore.globals$dim_RGBA) stop('not supported fRGBA format')

    rows <- dim(fRGBA)[1]
    cols <- dim(fRGBA)[2]

    A <- 255 / pmax(scattermore.globals$epsilon, fRGBA[,,scattermore.globals$A])  #"unpremultiply" alpha

    i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    i32RGBA[,,scattermore.globals$R] <- as.integer(fRGBA[,,scattermore.globals$R] * A)
    i32RGBA[,,scattermore.globals$G] <- as.integer(fRGBA[,,scattermore.globals$G] * A)
    i32RGBA[,,scattermore.globals$B] <- as.integer(fRGBA[,,scattermore.globals$B] * A)
    i32RGBA[,,scattermore.globals$A] <- as.integer(255 * fRGBA[,,scattermore.globals$A])

    return(i32RGBA)
}
