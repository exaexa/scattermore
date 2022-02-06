#' colorize_data
#'
#' Colorize given data with one given color or each point has its corresponding given color.
#'
#' @param xy 2-column float matrix with point coordinates. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the "usual" mathematical behavior.
#'
#' @param size 2-element vector integer size of the result histogram,
#'             defaults to `c(512,512)`.
#'
#' @param xlim, ylim Float limits as usual (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom), 2-element vector.
#'                   You can easily flip the top/bottom to the "usual" mathematical
#'                   system by flipping the `ylim` vector.
#'
#' @param rgba vector with 4 elements or matrix (4xn dim, n >= 2, n ~ xy rows) with R, G, B 
#'             and alpha channels  in integers, defaults to `c(0,0,0,255)`
#'
#' @param output_raster If the returned result is in raster form, defaults to `TRUE`. `FALSE`
#'                      for performing other operations.
#'
#' @return Raster or integer matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
colorize_data <- function(
  xy,
  xlim =c(min(xy[,1]),max(xy[,1])),
  ylim =c(min(xy[,2]),max(xy[,2])),
  size = c(512, 512),
  rgba = c(0,0,0,255),
  output_raster = TRUE)
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')
   
   if(!is.vector(xlim) || !is.vector(ylim) || !is.vector(size)) stop('vector input expected')
   
   if(is.vector(rgba))
   {
   	if(length(rgba) != 4) stop('rgba vector of length 4 expected')
   	n_col <- 1
   }
   else if(is.matrix(rgba))
   {
	if(dim(rgba)[1] != 4) stop('rgba matrix with 4 columns expected')
	n_col <- dim(rgba)[2]
	if(n_col != n) stop('incorrect number of colors')
   }
   else stop('unsupported rgba input')

   
   rows = size[1]
   cols = size[2]
   dim_rgbwt = 5
   dim_matrix = 4
      
   rgbwt <- rep(0, rows * cols * dim_rgbwt)
   rgbwt = array(rgbwt, c(rows, cols, dim_rgbwt))
   rgbwt[,,5] = 1  #initialize transparency (multiplying)
   
   if(n_col == 1)
   {
     result <- .C("data_one",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       rgba = as.single(rgba / 255),
       rgbwt = as.single(rgbwt),
       xy = as.single(xy))
   }
   else
   {
     result <- .C("data_more",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       rgba = as.single(rgba / 255),
       rgbwt = as.single(rgbwt),
       xy = as.single(xy))
   }
  
    rgbwt = array(result$rgbwt, c(rows, cols, dim_rgbwt))
    sum_alpha = rgbwt[,,4]
    R = ifelse(sum_alpha == 0, 0, rgbwt[,,1] / sum_alpha)  #preventing zero division
    G = ifelse(sum_alpha == 0, 0, rgbwt[,,2] / sum_alpha)
    B = ifelse(sum_alpha == 0, 0, rgbwt[,,3] / sum_alpha)
    A = 1 - rgbwt[,,5]
    
    matrix <- rep(0, rows * cols * dim_matrix)
    matrix = array(matrix, c(rows, cols, dim_matrix))
    matrix[,,1] = R
    matrix[,,2] = G
    matrix[,,3] = B
    matrix[,,4] = A
    
    colorized_data = array(as.integer(matrix * 255), c(rows, cols, dim_matrix))
    if(output_raster) return(grDevices::as.raster(colorized_data, max = 255)) else return(colorized_data)
}
