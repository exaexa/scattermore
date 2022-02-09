#' combine_two_rgbwt
#'
#' Blend two RGBWT matrices.
#'
#' @param fRGBWT_1 Float RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#'
#' @param fRGBWT_2 The same as fRGBWT_1 parameter.
#'
#' @return Float RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
combine_two_rgbwt <- function(fRGBWT_1, fRGBWT_2)
{
    dim_RGBWT <- 5
    if((!is.matrix(fRGBWT_1) && !is.array(fRGBWT_1)) || dim(fRGBWT_1)[3] != dim_RGBWT) stop('not supported fRGBWT_1 format')
    if((!is.matrix(fRGBWT_2) && !is.array(fRGBWT_2)) || dim(fRGBWT_2)[3] != dim_RGBWT) stop('not supported fRGBWT_2 format')
    if((dim(fRGBWT_1)[1] != dim(fRGBWT_2)[1]) || (dim(fRGBWT_1)[2] != dim(fRGBWT_2)[2])) stop('parameters do not have same dimensions')
    
    rows <- dim(fRGBWT_1)[1]
    cols <- dim(fRGBWT_1)[2]
    
    RGBWT <- rep(0, rows * cols * dim_RGBWT)  #initialize RGBWT
    RGBWT <- array(RGBWT, c(rows, cols, dim_RGBWT))
    RGBWT[,,1] <- fRGBWT_1[,,1] + fRGBWT_2[,,1]   #blend
    RGBWT[,,2] <- fRGBWT_1[,,2] + fRGBWT_2[,,2]
    RGBWT[,,3] <- fRGBWT_1[,,3] + fRGBWT_2[,,3]
    RGBWT[,,4] <- fRGBWT_1[,,4] + fRGBWT_2[,,4]
    RGBWT[,,5] <- fRGBWT_1[,,5] * fRGBWT_2[,,5]
    
    fRGBWT <- array(as.single(RGBWT), c(rows, cols, dim_RGBWT))
    return(fRGBWT)
}
