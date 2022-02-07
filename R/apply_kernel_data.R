#' apply_kernel_data
#'
#' Blur given rgbwt matrix using `circle` or `gauss` filtering.
#'
#' @param rgbwt Integer rgbwt matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha).
#'
#' @param radius Size of circle kernel (float), defaults to `2`.
#'
#' @param filter Either `circle` or `gaussian` (symmetric).
#'
#' @param sigma Parameter for gaussian filtering, defaults to `1`.
#'
#' @return Raster result or list with integer rgbwt and rgba matrices.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
apply_kernel_data <- function(
  rgbwt,
  rgba = NULL,
  filter = "circle",
  radius = 2,
  sigma = 1,
  output_raster = TRUE)
{
   if(!is.numeric(radius) || !is.numeric(sigma) || length(radius) != 1 || length(sigma) != 1) 
   	stop('number expected')
   if(radius <= 0) stop('positive radius expected')
   if(filter != "circle" && filter != "gauss") stop('"circle" or "gauss" kernel expected')
   
   dim_blurred <- 5
   dim_data <- 4
   
   if(filter == "circle")
   {
      if((!is.matrix(rgbwt) && !is.array(rgbwt)) || dim(rgbwt)[3] != 5) stop('not supported matrix format')
      rows <- dim(rgbwt)[1]
      cols <- dim(rgbwt)[2]
   }
   else
   {
      if((!is.matrix(rgba) && !is.array(rgba)) || dim(rgba)[3] != 4) stop('not supported matrix format')
      rows <- dim(rgba)[1]
      cols <- dim(rgba)[2]
   }

   
   blurred <- rep(0, rows * cols * dim_blurred)
   blurred <- array(blurred, c(rows, cols, dim_blurred))
   blurred[,,5] <- 1  #initialize transparency (multiplying)
   
   if(filter == "circle")
   {
      result <- .C("kernel_data_circle",
        dimen = as.integer(c(rows, cols)),
        radius = as.single(radius),
        blurred = as.single(blurred),
        rgbwt = as.single(rgbwt / 255))
   }
   else
   {
      result <- .C("kernel_data_gauss",
        dimen = as.integer(c(rows, cols)),
        blurred = as.single(blurred),
        rgba = as.single(rgba / 255),
        sigma = as.single(sigma))
   }
   
    blurred = array(result$blurred, c(rows, cols, dim_blurred))
    W <- blurred[,,4]
    R <- ifelse(W == 0, 0, blurred[,,1] / W)  #preventing zero division
    G <- ifelse(W == 0, 0, blurred[,,2] / W)
    B <- ifelse(W == 0, 0, blurred[,,3] / W)
    A <- 1 - blurred[,,5]

    matrix <- rep(0, rows * cols * dim_data)
    matrix <- array(matrix, c(rows, cols, dim_data))
    matrix[,,1] <- R
    matrix[,,2] <- G
    matrix[,,3] <- B
    matrix[,,4] <- A
    
    blurred_data <- array(as.integer(matrix * 255), c(rows, cols, dim_data))
    blurred <- array(as.integer(blurred*255), c(rows, cols, dim_blurred))
    if(output_raster) return(grDevices::as.raster(blurred_data, max = 255)) else return(list("rgbwt"=blurred, "rgba"=blurred_data))
}
