#' make_raster
#'
#' Create raster from given data.
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
#' @param rgba vector with 4 elements or matrix (4xn dim, n>= 2) with R, G, B 
#'             and alpha channels  in integers, defaults to `c(64,128,192,10)`
#'
#' @return float matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
make_raster <- function(
  xy,
  xlim =c(min(xy[,1]),max(xy[,1])),
  ylim =c(min(xy[,2]),max(xy[,2])),
  size = c(512, 512),
  rgba = c(64,128,192,10))
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
   }
   else stop('unsupported rgba input')

   
   rows = size[2]
   cols = size[1]
   
   matrix <- rep(0, rows * cols * 4)
   
   result <- .C("raster",
     dimen = as.integer(c(rows, cols, size, n_col)),
     matrix = as.single(matrix),
     rgba = as.single(rgba) / 255,
     xy = as.single(xy))

    raster = array(as.integer(result$matrix * 255), c(rows, cols, 4))
    return(grDevices::as.raster(raster, max = 255))
}
