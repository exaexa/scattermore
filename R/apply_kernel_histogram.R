#' apply_kernel_histogram
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param fhistogram Matrix or array interpreted as histogram.
#'
#' @param filter Either `circle`, `square` or `gauss`, defaults to `circle`.
#'
#' @param kernel
#'
#' @param radius Used for determining size of kernel, defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `radius / 2`.
#'
#' @return Blurred histogram with the result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_histogram <- function(
  fhistogram,
  filter = "circle",
  kernel,
  radius = 2,
  sigma = radius / 2)
{

   if(!is.matrix(fhistogram) && !is.array(fhistogram)) stop('fhistogram in matrix form expected')
   if(dim(fhistogram)[2] < 2) stop('not fhistogram format')
   if(!is.numeric(radius) || !is.numeric(sigma) || length(radius) != 1 || length(sigma) != 1)
       stop('number in parameters radius or sigma')
   if(radius <= 0) stop('positive radius expected')


   size_y <- dim(fhistogram)[1]
   size_x <- dim(fhistogram)[2]

   kernel_pixels <- ceiling(radius)
   size <- kernel_pixels * 2 + 1;  #odd size

   if(filter == "circle")
   {
      kernel <- matrix(
          pmin(1, pmax(0, -sqrt(rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels) ^ 2)) + radius)),
        size, size)
   }
   else if(filter == "square")
       kernel <- rep(1, size * size) #initialize and normalize kernel
   else if(filter == "gauss")
   {
      kernel <- matrix(
        exp(
          -rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels) ^ 2)
           / (sigma ^ 2)),
        size, size)
   }
   else if(filter == "own")
   {

   }
   else stop('unsupported kernel shape')


   result <- .C("kernel_histogram",
       dimen = as.integer(c(size_x, size_y, kernel_pixels)),
       kernel = as.single(kernel),
       blurred_fhistogram = as.single(rep(0, size_x * size_y)),
       fhistogram = as.single(fhistogram))

   blurred_fhistogram <- array(result$blurred_fhistogram, c(size_y, size_x))
   return(blurred_fhistogram)
}
