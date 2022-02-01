#' apply_kernel_hist
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param hist matrix or array R datatype interpreted as histogram
#'
#' @param kernel_pixels used for determining size of kernel,
#'                      (`size = 2*kernel_pixels + 1`), defaults to `2`.
#'
#' @param filter either `square`(matrix of ones) or `gaussian` (symmetric)
#'
#' @param sigma parameter for gaussian filtering, defaults to `10`
#'
#' @return float matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_hist <- function(
  hist,
  filter = "square",
  kernel_pixels = 2,
  sigma = 10)
{
   rows = dim(hist)[1]
   cols = dim(hist)[2]
   
   if(!is.integer(rows) || !is.integer(cols)) stop('input with rows and columns expected')
   
   size = 2*kernel_pixels + 1
   mat <- rep(0, rows * cols)
   
   if(filter == "square")
   {
      kernel <- rep(1, size * size)
      kernel = kernel / sum(kernel)     #normalize kernel 
   
      result <- .C("kernel_hist_square",
        dimen = as.integer(c(rows, cols, size)),
        kernel = as.single(kernel),
        mat = as.single(mat),
        hist = as.single(hist))
   }
   else if(filter == "gauss")
   {
      result <- .C("kernel_hist_gauss",
        dimen = as.integer(c(rows, cols, size)),
        mat = as.single(mat),
        hist = as.single(hist),
        sigma = as.single(sigma))
   }
   else
   	stop('"classic" or "gauss" kernel expected')

    blurred_hist = array(as.single(result$mat), c(rows, cols))
    return(blurred_hist)
}
