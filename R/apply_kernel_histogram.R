#' apply_kernel_histogram
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param fhistogram Matrix or array interpreted as histogram.
#'
#' @param filter Either `square`(matrix of ones) or `gaussian` (symmetric).
#'
#' @param kernel_pixels Used for determining size of kernel,
#'                      (`size = 2*kernel_pixels + 1`), defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `10`.
#'
#' @return Blurred histogram with the result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_histogram <- function(
  fhistogram,
  filter = "square",
  kernel_pixels = 2,
  sigma = kernel_pixels / 2)
{

   if(!is.matrix(fhistogram) && !is.array(fhistogram)) stop('fhistogram in matrix form expected')
   if(dim(fhistogram)[2] < 2) stop('not fhistogram format')
   if(!is.numeric(kernel_pixels) || !is.numeric(sigma) || length(kernel_pixels) != 1 || length(sigma) != 1)
   	stop('number expected')
   if(filter != "square" && filter != "gauss") stop('"square" or "gauss" kernel expected')

   size_y <- dim(fhistogram)[1]
   size_x <- dim(fhistogram)[2]

   size <- 2 * kernel_pixels + 1 #odd size

   if(filter == "square")
   {
      kernel <- rep(1, size * size) #initialize and normalize kernel

      result <- .C("kernel_histogram",
        dimen = as.integer(c(size_x, size_y, kernel_pixels)),
        kernel = as.single(kernel),
        blurred_histogram = as.single(rep(0, size_x * size_y)),
        fhistogram = as.single(fhistogram))
   }
   else
   {
      kernel <- matrix(
        exp(
          -rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels) ^ 2)
           /(sigma ^ 2)),
        size, size)

      result <- .C("kernel_histogram",
        dimen = as.integer(c(size_x, size_y, kernel_pixels)),
        kernel = as.single(kernel),
        blurred_histogram = as.single(rep(0, size_x * size_y)),
        fhistogram = as.single(fhistogram))
   }

    blurred_histogram <- array(result$blurred_histogram, c(size_y, size_x))
    return(blurred_histogram)
}
