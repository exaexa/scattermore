#' apply_kernel_hist
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param hist Matrix or array R datatype interpreted as histogram.
#'
#' @param kernel_pixels Used for determining size of kernel,
#'                      (`size = 2*kernel_pixels + 1`), defaults to `2`.
#'
#' @param filter Either `square`(matrix of ones) or `gaussian` (symmetric).
#'
#' @param sigma Parameter for gaussian filtering, defaults to `10`.
#'
#' @return Float matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_hist <- function(
  hist,
  filter = "square",
  kernel_pixels = 2,
  sigma = 10)
{

   if(!is.matrix(hist) && !is.array(hist)) stop('histogram in matrix form expected')
   if(dim(hist)[2] < 2) stop('not supported matrix format')
   if(!is.numeric(kernel_pixels) || !is.numeric(sigma) || length(kernel_pixels) != 1 || length(sigma) != 1) 
   	stop('number expected')
   if(filter != "square" && filter != "gauss") stop('"square" or "gauss" kernel expected')
   	
   rows <- dim(hist)[1]
   cols <- dim(hist)[2]  
   
   size = 2*kernel_pixels + 1
   matrix <- rep(0, rows * cols)
   
   if(filter == "square")
   {
      kernel <- rep(1, size * size)
      kernel = kernel / sum(kernel)     #normalize kernel 
   
      result <- .C("kernel_hist_square",
        dimen = as.integer(c(rows, cols, size)),
        kernel = as.single(kernel),
        matrix = as.single(matrix),
        hist = as.single(hist))
   }
   else
   {
      result <- .C("kernel_hist_gauss",
        dimen = as.integer(c(rows, cols, size)),
        matrix = as.single(matrix),
        hist = as.single(hist),
        sigma = as.single(sigma))
   }

    blurred_hist = array(as.single(result$matrix), c(rows, cols))
    return(blurred_hist)
}
