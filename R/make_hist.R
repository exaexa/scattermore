#' make_histogram
#'
#' Create histogram from given point coordinates.
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
#' @param out_size 2-element vector integer size of the result histogram,
#'             defaults to `c(512,512)`.
#'
#' @return Float histogram with the result (values ~ 0-1).
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
make_histogram <- function(
  xy,
  xlim =c(min(xy[,1]),max(xy[,1])),
  ylim =c(min(xy[,2]),max(xy[,2])),
  out_size = c(512, 512))
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')
   
   if(!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size)) stop('vector input expected')
   
   rows <- out_size[1]
   cols <- out_size[2]
   histogram <- rep(0, rows * cols)  #initialize histogram
   
   result <- .C("hist_int",
     n = as.integer(n),
     out_size = as.integer(out_size),
     i32histogram = as.integer(histogram),
     xlim = as.single(xlim),
     ylim = as.single(ylim),
     xy = as.single(xy))
     
    fhistogram <- array(as.single(result$i32histogram/255), c(rows, cols)) #change to values 0-1
    return(fhistogram)
}
