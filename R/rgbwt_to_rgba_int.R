#' rgbwt_to_rgba_int
#'
#' Convert fRGBWT matrix to integer RGBA matrix.
#'
#' @param fRGBWT float fRGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return Integer RGBA matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
rgbwt_to_rgba_int <- function(fRGBWT)
{
    dim_RGBWT <- 5
    if((!is.matrix(fRGBWT) && !is.array(fRGBWT)) || dim(fRGBWT)[3] != dim_RGBWT) stop('not supported fRGBWT format')
    
    rows <- dim(fRGBWT)[1]
    cols <- dim(fRGBWT)[2]
    dim_RGBA <- 4
    
    fRGBWT <- array(as.single(fRGBWT), c(rows, cols, dim_RGBWT))
    W <- fRGBWT[,,4]
    R <- ifelse(W == 0, 0, fRGBWT[,,1] / W)  #preventing zero division
    G <- ifelse(W == 0, 0, fRGBWT[,,2] / W)
    B <- ifelse(W == 0, 0, fRGBWT[,,3] / W)
    A <- 1 - fRGBWT[,,5]
    
    RGBA <- rep(0, rows * cols * dim_RGBA)  #initialize matrix
    RGBA <- array(RGBA, c(rows, cols, dim_RGBA))
    RGBA[,,1] <- R
    RGBA[,,2] <- G
    RGBA[,,3] <- B
    RGBA[,,4] <- A
    
    i32RGBA <- array(as.integer(RGBA*255), c(rows, cols, dim_RGBA))
    return(i32RGBA)
}
