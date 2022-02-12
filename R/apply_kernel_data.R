#' apply_kernel_data
#'
#' Blur given RGBWT matrix using `circle` or `gauss` filtering.
#'
#' @param RGBWT Float RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
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
#' @return Float RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_data <- function(
  fRGBWT,
  RGBA = NULL,
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
   rows <- dim(fRGBWT)[1]
   cols <- dim(fRGBWT)[2]

   
   blurred_RGBWT <- rep(0, rows * cols * dim_RGBWT)  #initialize blurred RGBWT matrix
   blurred_RGBWT <- array(blurred_RGBWT, c(rows, cols, dim_RGBWT))
   blurred_RGBWT[,,5] <- 1  #initialize transparency (multiplying)
   
   if(filter == "circle")
   {
      result <- .C("kernel_data_circle",
        dimen = as.integer(c(rows, cols)),
        radius = as.single(radius),
        blurred_fRGBWT = as.single(blurred_RGBWT),
        fRGBWT = as.single(fRGBWT))
   }
   else
   {
      result <- .C("kernel_data_gauss",
        dimen = as.integer(c(rows, cols)),
        blurred_fRGBWT = as.single(blurred_RGBWT),
        fRGBWT = as.single(fRGBWT),
        approx_limit = as.single(approx_limit),
        sigma = as.single(sigma))
   }

    blurred_fRGBWT <- array(result$blurred_fRGBWT, c(rows, cols, dim_RGBWT))
    return(blurred_fRGBWT)
}
