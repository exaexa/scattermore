#' make_hist
#'
#' Create histogram from given point coordinates.
#'
#' @param xy 2-column float matrix with point coordinates. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the "usual" mathematical behavior.
#' @param size 2-element vector integer size of the result histogram,
#'             defaults to `c(512,512)`.
#' @param xlim, ylim Float limits as usual (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom). You can
#'                   easily flip the top/bottom to the "usual" mathematical
#'                   system by flipping the `ylim` vector.
#' @return integer matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
make_hist <- function(
  xy,
  xlim =c(min(xy[,1]),max(xy[,1])),
  ylim =c(min(xy[,2]),max(xy[,2])),
  size = c(512, 512))
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')
   
   
   mat <- rep(0, size[1] * size[2])
   
   result <- .C("hist_int",
     n = as.integer(n),
     size = as.integer(size),
     mat = as.integer(mat),
     xlim = as.single(xlim),
     ylim = as.single(ylim),
     xy = as.single(xy))
     
    
    return(array(result$mat, c(size[2], size[1])))
}
