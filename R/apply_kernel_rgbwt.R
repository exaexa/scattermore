#' apply_kernel_rgbwt
#'
#' Blur given RGBWT matrix using `circle` or `gauss` filtering.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#'
#' @param filter Either `circle` or `gaussian` (symmetric).
#'
#' @param radius Size of circle kernel (float), defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `1`.
#'
#' @param approx_limit Sets the size of the kernel square, multiplied with `sigma`, defaults to `3.5`.
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_rgbwt <- function(
  fRGBWT,
  filter = "circle",
  radius = 2,
  sigma = 1,
  approx_limit = 3.5)
{
   if(!is.numeric(radius) || !is.numeric(sigma) || !is.numeric(approx_limit) || length(radius) != 1 || length(sigma) != 1|| length(approx_limit) != 1)
   	stop('number in parameters radius, sigma or approx_limit expected')
   if(radius <= 0) stop('positive radius expected')
   if(filter != "circle" && filter != "gauss") stop('"circle" or "gauss" kernel expected')

   dim_RGBWT <- 5

   if(!is.array(fRGBWT) || dim(fRGBWT)[3] != 5) stop('not supported fRGBWT format')
   size_y <- dim(fRGBWT)[1]
   size_x <- dim(fRGBWT)[2]

   output_RGBWT <- array(0, c(size_y, size_x, dim_RGBWT))
   output_RGBWT[,,5] <- 1  #initialize transparency (multiplying)

   if(filter == "circle")
   {
      # TODO: this is expressible using the "prepared" kernels (kernel_gauss_rgbwt)
      result <- .C("kernel_circle_rgbwt",
        dimen = as.integer(c(size_x, size_y)),
        radius = as.single(radius),
        output_RGBWT = as.single(output_RGBWT),
        fRGBWT = as.single(fRGBWT))
   }
   else
   {
      kernel_pixels <- ceiling(sigma * approx_limit);  #size of the kernel
      size <- kernel_pixels * 2 + 1;  #odd size
      kernel <- matrix(
        exp(
          -rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels)^2)
           /(sigma^2)),
        size, size)

      kernel <- kernel/sum(kernel)

      result <- .C("kernel_gauss_rgbwt",
        dimen = as.integer(c(size_x, size_y, kernel_pixels)),
        kernel = as.single(kernel),
        output_RGBWT = as.single(output_RGBWT),
        fRGBWT = as.single(fRGBWT))
   }

    output_RGBWT <- array(result$output_RGBWT, c(size_y, size_x, dim_RGBWT))
    return(output_RGBWT)
}
