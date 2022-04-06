#' rgbwt_to_rgba_float
#'
#' Convert RGBWT matrix to RGBA matrix.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgbwt_to_rgba_float <- function(fRGBWT)
{
    if(!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop('not supported fRGBWT format')

    rows <- dim(fRGBWT)[1]
    cols <- dim(fRGBWT)[2]

    W <- pmin(1, 1 / fRGBWT[,,4])
    A <- 1 - fRGBWT[,,5]

    fRGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    fRGBA[,,1] <- (fRGBWT[,,1] * W) * A   #store premultiplied alpha
    fRGBA[,,2] <- (fRGBWT[,,2] * W) * A
    fRGBA[,,3] <- (fRGBWT[,,3] * W) * A
    fRGBA[,,4] <- A

    return(fRGBA)
}
