#' apply_kernel_data
#'
#' Blur given rgbwt matrix using `circle` or `gauss` filtering.
#'
#' @param hist Integer rgbwt matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha).
#'
#' @param kernel_pixels Used for determining size of kernel,
#'                      (`size = 2*kernel_pixels + 1`), defaults to `2`.
#'
#' @param filter Either `circle` or `gaussian` (symmetric).
#'
#' @param sigma Parameter for gaussian filtering, defaults to `10`.
#'
#' @return Raster or integer matrix with the resul
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_data <- function(
  rgbwt,
  filter = "circle",
  kernel_pixels = 2,
  sigma = 10,
  output_raster = TRUE)
{
   if((!is.matrix(rgbwt) && !is.array(rgbwt)) || dim(rgbwt)[3] != 5) stop('not supported matrix format')
   if(!is.numeric(kernel_pixels) || !is.numeric(sigma) || length(kernel_pixels) != 1 || length(sigma) != 1) 
   	stop('number expected')
   if(filter != "circle" && filter != "gauss") stop('"circle" or "gauss" kernel expected')
   	
   rows <- dim(rgbwt)[1]
   cols <- dim(rgbwt)[2]
   dim_blurred = 5
   dim_data = 4
   
   size = 2*kernel_pixels + 1
   blurred <- rep(0, rows * cols * dim_blurred)
   
   if(filter == "circle")
   {
      kernel <- rep(1, size * size)
      kernel = kernel / sum(kernel)     #normalize kernel 
   
      result <- .C("kernel_data_circle",
        dimen = as.integer(c(rows, cols, size)),
        kernel = as.single(kernel),
        blurred = as.single(blurred),
        rgbwt = as.single(rgbwt / 255))
   }
   else
   {
      result <- .C("kernel_data_gauss",
        dimen = as.integer(c(rows, cols, size)),
        blurred = as.single(blurred),
        rgbwt = as.single(rgbwt / 255),
        sigma = as.single(sigma))
   }
   
    blurred = array(result$blurred, c(rows, cols, dim_blurred))
    W = blurred[,,4]
    R = ifelse(W == 0, 0, blurred[,,1] / W)  #preventing zero division
    G = ifelse(W == 0, 0, blurred[,,2] / W)
    B = ifelse(W == 0, 0, blurred[,,3] / W)
    A = 1 - blurred[,,5]

    matrix <- rep(0, rows * cols * dim_data)
    matrix = array(matrix, c(rows, cols, dim_data))
    matrix[,,1] = R
    matrix[,,2] = G
    matrix[,,3] = B
    matrix[,,4] = A
    
    blurred_data = array(as.integer(matrix * 255), c(rows, cols, dim_data))
    if(output_raster) return(grDevices::as.raster(blurred_data, max = 255)) else return(blurred_data)
}
