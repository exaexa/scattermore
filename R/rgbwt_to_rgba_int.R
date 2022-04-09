#' rgbwt_to_rgba_int
#'
#' Convert RGBWT matrix to integer RGBA matrix.
#'
#' @param fRGBWT fRGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix, output *is not premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgbwt_to_rgba_int <- function(fRGBWT)
{
    if(!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop('not supported fRGBWT format')

    rows <- dim(fRGBWT)[1]
    cols <- dim(fRGBWT)[2]

    W <- 255 / pmax(scattermore.globals$epsilon, fRGBWT[,,scattermore.globals$W])

    i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    i32RGBA[,,scattermore.globals$R] <- as.integer(fRGBWT[,,scattermore.globals$R] * W)
    i32RGBA[,,scattermore.globals$G] <- as.integer(fRGBWT[,,scattermore.globals$G] * W)
    i32RGBA[,,scattermore.globals$B] <- as.integer(fRGBWT[,,scattermore.globals$B] * W)
    i32RGBA[,,scattermore.globals$A] <- as.integer(255 * (1 - fRGBWT[,,scattermore.globals$T]))

    return(i32RGBA)
}
