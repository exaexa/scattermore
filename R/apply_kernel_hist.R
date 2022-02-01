#' apply_kernel_hist
#'
#' Blur given histogram using `classic` or `gauss` filtering.
#'
#' @param hist float matrix or array R datatype interpreted as histogram
#'
#' @param size dimension of kernel that is used, changed to odd it not,
#'             defaults to `5`.
#'
#' @param filter either `classic`(matrix of ones) or `gaussian` (symmetric)
#'
#' @param sigma parameter for gaussian filtering, defaults to `1.0`
#'
#' @return float matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_hist <- function(
  hist,
  filter = "classic",
  size = 5,
  sigma = 1.0)
{
   rows = dim(hist)[1]
   cols = dim(hist)[2]
   
   if(!is.integer(rows) || !is.integer(cols)) stop('input with rows and columns expected')
   
   if(size %% 2 == 0) size = size + 1    #change even size of kernel to odd size

   mat <- rep(0, rows * cols)
   
   
   if(filter == "classic")
   {
      kernel <- rep(1, size * size)
      kernel = kernel / sum(kernel)     #normalize kernel 
   
      result <- .C("kernel_hist_classic",
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
