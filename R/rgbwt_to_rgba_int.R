#' rgbwt_to_rgba_int
#'
#' Convert rgbwt matrix to integer rgba matrix.
#'
#' @param rgbwt float rgbwt matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return Integer rgba matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
rgbwt_to_rgba_int <- function(rgbwt)
{
    dim_rgbwt <- 5
    if((!is.matrix(rgbwt) && !is.array(rgbwt)) || dim(rgbwt)[3] != dim_rgbwt) stop('not supported matrix format')
    
    rows <- dim(rgbwt)[1]
    cols <- dim(rgbwt)[2]
    dim_rgba <- 4
    
    rgbwt <- array(as.single(rgbwt), c(rows, cols, dim_rgbwt))
    W <- rgbwt[,,4]
    R <- ifelse(W == 0, 0, rgbwt[,,1] / W)  #preventing zero division
    G <- ifelse(W == 0, 0, rgbwt[,,2] / W)
    B <- ifelse(W == 0, 0, rgbwt[,,3] / W)
    A <- 1 - rgbwt[,,5]
    
    rgba <- rep(0, rows * cols * dim_rgba)  #initialize matrix
    rgba <- array(rgba, c(rows, cols, dim_rgba))
    rgba[,,1] <- R
    rgba[,,2] <- G
    rgba[,,3] <- B
    rgba[,,4] <- A
    
    rgba <- array(as.integer(rgba*255), c(rows, cols, dim_rgba))
    return(rgba)
}
