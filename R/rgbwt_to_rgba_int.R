#' rgbwt_to_rgba_int
#'
#' Convert RGBWT matrix to integer RGBA matrix.
#'
#' @param fRGBWT fRGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgbwt_to_rgba_int <- function(fRGBWT)
{
    if(!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop('not supported fRGBWT format')

    rows <- dim(fRGBWT)[1]
    cols <- dim(fRGBWT)[2]

    W <- pmin(255, 255 / (fRGBWT[,,4] * (1 - fRGBWT[,,5])))

    i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    i32RGBA[,,1] <- as.integer(fRGBWT[,,1] * W)
    i32RGBA[,,2] <- as.integer(fRGBWT[,,2] * W)
    i32RGBA[,,3] <- as.integer(fRGBWT[,,3] * W)
    i32RGBA[,,4] <- as.integer(255 * (1 - fRGBWT[,,5]))

    return(i32RGBA)
}
