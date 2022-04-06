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
    dim_RGBA <- 4
    if(!is.array(fRGBA_1) || dim(fRGBA_1)[3] != dim_RGBA) stop('not supported fRGBA_1 format')
    if(!is.array(fRGBA_2) || dim(fRGBA_2)[3] != dim_RGBA) stop('not supported fRGBA_2 format')
    if((dim(fRGBA_1)[1] != dim(fRGBA_2)[1]) || (dim(fRGBA_1)[2] != dim(fRGBA_2)[2])) stop('parameters do not have same dimensions')

    rows <- dim(fRGBA_1)[1]
    cols <- dim(fRGBA_1)[2]

    A_1 <- fRGBA_1[,,4]
    A_2 <- fRGBA_2[,,4]

    RGBA <- array(0, c(rows, cols, dim_RGBA))
    RGBA[,,1] <- fRGBA_1[,,1] + (fRGBA_2[,,1] * (1-A_1))  #blend with premultiplied alpha
    RGBA[,,2] <- fRGBA_1[,,2] + (fRGBA_2[,,2] * (1-A_1))
    RGBA[,,3] <- fRGBA_1[,,3] + (fRGBA_2[,,3] * (1-A_1))
    RGBA[,,4] <- A_1 + (A_2 * (1 - A_1))

    fRGBA <- array(RGBA, c(rows, cols, dim_RGBA))
    return(fRGBA)
}
