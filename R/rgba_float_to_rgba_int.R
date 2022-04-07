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

    A <- 255 / pmax(scattermore.globals$epsilon, fRGBA[,,4])  #"unpremultiply" alpha

    i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    i32RGBA[,,1] <- as.integer(fRGBA[,,1] * A)
    i32RGBA[,,2] <- as.integer(fRGBA[,,2] * A)
    i32RGBA[,,3] <- as.integer(fRGBA[,,3] * A)
    i32RGBA[,,4] <- as.integer(255 * fRGBA[,,4])

    return(i32RGBA)
}
