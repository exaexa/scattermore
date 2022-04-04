#' apply_kernel_histogram
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param fhistogram Matrix or array R datatype interpreted as histogram.
#'
#' @param filter Either `square`(matrix of ones) or `gaussian` (symmetric).
#'
#' @param kernel_pixels Used for determining size of kernel,
#'                      (`size = 2*kernel_pixels + 1`), defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `10`.
#'
#' @return Float blurred histogram with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_histogram <- function(
  fhistogram,
  filter = "square",
  kernel_pixels = 2,
  sigma = 10)
{

   if(!is.matrix(fhistogram) && !is.array(fhistogram)) stop('fhistogram in matrix form expected')
   if(dim(fhistogram)[2] < 2) stop('not fhistogram format')
   if(!is.numeric(kernel_pixels) || !is.numeric(sigma) || length(kernel_pixels) != 1 || length(sigma) != 1) 
   	stop('number expected')
   if(filter != "square" && filter != "gauss") stop('"square" or "gauss" kernel expected')
   	
   rows <- dim(fhistogram)[1]
   cols <- dim(fhistogram)[2]  
   
   size <- 2*kernel_pixels + 1
   blurred_histogram <- rep(0, rows * cols) #initialize blurred histogram
   
   if(filter == "square")
   {
      kernel <- rep(1, size * size) #initialize and normalize kernel
      kernel <- kernel / sum(kernel)
   
      result <- .C("kernel_square_histogram",
        dimen = as.integer(c(rows, cols, size)),
        kernel = as.single(kernel),
        blurred_histogram = as.single(blurred_histogram),
        fhistogram = as.single(fhistogram))
   }
   else
   {
      result <- .C("kernel_gauss_histogram",
        dimen = as.integer(c(rows, cols, size)),
        blurred_histogram = as.single(blurred_histogram),
        fhistogram = as.single(fhistogram),
        sigma = as.single(sigma))
   }

    blurred_histogram <- array(result$blurred_histogram, c(rows, cols))
    return(blurred_histogram)
}
