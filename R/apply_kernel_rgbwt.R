#' apply_kernel_rgbwt
#'
#' Blur given RGBWT matrix using `circle` or `gauss` filtering.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#'
#' @param filter Either `circle`, `square`, `gauss` or `own`, defaults to `circle.
#'
#' @param mask Own kernel used for blurring, `filter` parameter has to be set to `own`.
#'
#' @param radius Size of circle kernel, defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `radius / 2`.
#'
#' @param approx_limit Sets the size of the kernel, multiplied with `sigma`, defaults to `3.5`.
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_rgbwt <- function(
  fRGBWT,
  filter = "circle",
  mask,
  radius = 2,
  sigma = radius / 2,
  approx_limit = 3.5)
{
    if(!is.numeric(radius) || !is.numeric(sigma) || !is.numeric(approx_limit) || length(radius) != 1 || length(sigma) != 1|| length(approx_limit) != 1)
   	stop('number in parameters radius, sigma or approx_limit expected')
    if(radius <= 0) stop('positive radius expected')

    if(!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop('not supported fRGBWT format')
    size_y <- dim(fRGBWT)[1]
    size_x <- dim(fRGBWT)[2]

    blurred_fRGBWT <- array(0, c(size_y, size_x, scattermore.globals$dim_RGBWT))
    blurred_fRGBWT[,,scattermore.globals$T] <- 1  #initialize transparency (multiplying)

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
       kernel_pixels <- ceiling(sigma * approx_limit);  #size of the kernel
       size <- kernel_pixels * 2 + 1;  #odd size
       kernel <- matrix(
           exp(
               -rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels) ^ 2)
                / (sigma ^ 2)),
       size, size)
    }
    else if(filter == "own")
    {
         if(!is.matrix(mask) && !is.array(mask)) stop('kernel in matrix or array form expected')
         if(dim(mask)[1] != dim(mask)[2]) stop('kernel in square matrix expected')
         if(dim(mask)[1] %% 2 == 0) stop('kernel with odd size expected')

         kernel <- mask
         kernel_pixels <- floor(dim(kernel)[1] / 2)
    }
    else stop('unsupported kernel shape')


    result <- .C("kernel_rgbwt",
        dimen = as.integer(c(size_x, size_y, kernel_pixels)),
        kernel = as.single(kernel),
        blurred_fRGBWT = as.single(blurred_fRGBWT),
        fRGBWT = as.single(fRGBWT))

    blurred_fRGBWT <- array(result$blurred_fRGBWT, c(size_y, size_x, scattermore.globals$dim_RGBWT))
    return(blurred_fRGBWT)
}
