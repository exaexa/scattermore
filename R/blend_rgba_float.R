#' blend_rgba_float
#'
#' Blend two RGBA matrices.
#'
#' @param fRGBA_1 RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @param fRGBA_2 The same as fRGBA_1 parameter.
#'
#' @return RGBA matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
blend_rgba_float <- function(fRGBA_1, fRGBA_2)
{
    if(!is.array(fRGBA_1) || dim(fRGBA_1)[3] != scattermore.globals$dim_RGBA) stop('not supported fRGBA_1 format')
    if(!is.array(fRGBA_2) || dim(fRGBA_2)[3] != scattermore.globals$dim_RGBA) stop('not supported fRGBA_2 format')
    if((dim(fRGBA_1)[1] != dim(fRGBA_2)[1]) || (dim(fRGBA_1)[2] != dim(fRGBA_2)[2])) stop('parameters do not have same dimensions')

    rows <- dim(fRGBA_1)[1]
    cols <- dim(fRGBA_1)[2]

    A_1 <- fRGBA_1[,,scattermore.globals$A]
    A_2 <- fRGBA_2[,,scattermore.globals$A]

    fRGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    fRGBA[,,scattermore.globals$R] <- fRGBA_1[,,scattermore.globals$R] + (fRGBA_2[,,scattermore.globals$R] * (1 - A_1))  #blend with premultiplied alpha
    fRGBA[,,scattermore.globals$G] <- fRGBA_1[,,scattermore.globals$G] + (fRGBA_2[,,scattermore.globals$G] * (1 - A_1))
    fRGBA[,,scattermore.globals$B] <- fRGBA_1[,,scattermore.globals$B] + (fRGBA_2[,,scattermore.globals$B] * (1 - A_1))
    fRGBA[,,scattermore.globals$A] <- A_1 + (A_2 * (1 - A_1))

    return(fRGBA)
}
