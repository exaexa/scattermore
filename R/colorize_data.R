#' colorize_data
#'
#' Colorize given data with one given color or each point has its corresponding given color.
#'
#' @param xy 2-column float matrix with point coordinates. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the "usual" mathematical behavior.
#'
#' @param xlim, ylim Float limits as usual (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom), 2-element vector.
#'                   You can easily flip the top/bottom to the "usual" mathematical
#'                   system by flipping the `ylim` vector.
#'
#' @param size 2-element vector integer size of the result histogram,
#'             defaults to `c(512,512)`.
#'
#' @param RGBA Integer vector with 4 elements or matrix or array (4xn dim, n >= 2, n ~ xy rows) with R, G, B 
#'             and alpha channels  in integers, defaults to `c(0,0,0,255)`.
#'
#' @return Float RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
colorize_data <- function(
  xy,
  xlim =c(min(xy[,1]),max(xy[,1])),
  ylim =c(min(xy[,2]),max(xy[,2])),
  size = c(512, 512),
  RGBA = c(0,0,0,255))
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')
   
   if(!is.vector(xlim) || !is.vector(ylim) || !is.vector(size)) stop('vector input expected')
   
   if(is.vector(RGBA))
   {
   	if(length(RGBA) != 4) stop('rgba vector of length 4 expected')
   	n_col <- 1
   }
   else if(is.matrix(RGBA) || is.array(rgba))
   {
	if(dim(RGBA)[1] != 4) stop('rgba matrix with 4 columns expected')
	n_col <- dim(RGBA)[2]
	if(n_col != n) stop('incorrect number of colors')
   }
   else stop('unsupported rgba input')

   
   rows <- size[1]
   cols <- size[2]
   dim_RGBWT <- 5
      
   RGBWT <- rep(0, rows * cols * dim_RGBWT)  #initialize RGBWT
   RGBWT <- array(RGBWT, c(rows, cols, dim_RGBWT))
   RGBWT[,,5] <- 1  #initialize transparency (multiplying)
   
   if(n_col == 1)
   {
     result <- .C("data_one",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       RGBA = as.single(RGBA/255),
       fRGBWT = as.single(RGBWT),
       xy = as.single(xy))
   }
   else
   {
     result <- .C("data_more",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       RGBA = as.single(RGBA/255),
       fRGBWT = as.single(RGBWT),
       xy = as.single(xy))
   }
  
    fRGBWT <- array(result$fRGBWT, c(rows, cols, dim_RGBWT))
    return(fRGBWT)
}
