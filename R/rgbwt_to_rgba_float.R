#' rgbwt_to_rgba_float
#'
#' Convert RGBWT matrix to RGBA matrix.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix, output *is premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgbwt_to_rgba_float <- function(fRGBWT)
{
    if(!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop('not supported fRGBWT format')

    rows <- dim(fRGBWT)[1]
    cols <- dim(fRGBWT)[2]

    A <- 1 - fRGBWT[,,scattermore.globals$T]
    W <- A / pmax(scattermore.globals$epsilon, fRGBWT[,,scattermore.globals$W])

    fRGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    fRGBA[,,scattermore.globals$R] <- fRGBWT[,,scattermore.globals$R] * W   #we store premultiplied alpha!
    fRGBA[,,scattermore.globals$G] <- fRGBWT[,,scattermore.globals$G] * W
    fRGBA[,,scattermore.globals$B] <- fRGBWT[,,scattermore.globals$B] * W
    fRGBA[,,scattermore.globals$A] <- A

    return(fRGBA)
}
