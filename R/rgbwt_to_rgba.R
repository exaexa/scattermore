#' rgbwt_to_rgba
#'
#' Convert rgbwt matrix to rgba matrix.
#'
#' @param rgbwt Integer rgbwt matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return Integer rgba matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
rgbwt_to_rgba <- function(rgbwt)
{
    dim_rgbwt <- 5
    if((!is.matrix(rgbwt) && !is.array(rgbwt)) || dim(rgbwt)[3] != dim_rgbwt) stop('not supported matrix format')
    
    rows <- dim(rgbwt)[1]
    cols <- dim(rgbwt)[2]
    dim_matrix <- 4
    
    rgbwt <- array(as.single(rgbwt/255), c(rows, cols, dim_rgbwt))
    W <- rgbwt[,,4]
    R <- ifelse(W == 0, 0, rgbwt[,,1] / W)  #preventing zero division
    G <- ifelse(W == 0, 0, rgbwt[,,2] / W)
    B <- ifelse(W == 0, 0, rgbwt[,,3] / W)
    A <- 1 - rgbwt[,,5]
    
    matrix <- rep(0, rows * cols * dim_matrix)  #initialize matrix
    matrix <- array(matrix, c(rows, cols, dim_matrix))
    matrix[,,1] <- R
    matrix[,,2] <- G
    matrix[,,3] <- B
    matrix[,,4] <- A
    
    data <- array(as.integer(matrix*255), c(rows, cols, dim_matrix))
    return(data)
}
