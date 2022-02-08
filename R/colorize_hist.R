#' colorize_hist
#'
#' Colorize given histogram with input palette.
#'
#' @param hist Matrix or array R datatype interpreted as histogram.
#'
#' @param rgba Matrix (4xn dim, n>= 2) with R, G, B and alpha channels 
#'             in integers, defaults to shades of `red`, `green` and `blue` with `alpha = 255`.
#'
#' @return Float rgbwt matrix.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
colorize_hist <- function(
  hist,
  rgba = array(c(250,128,114,255,144,238,144,255,176,224,230,255), c(4,3)))
{  
   if(!is.matrix(hist) && !is.array(hist)) stop('histogram in matrix form expected')
   if(dim(hist)[2] < 2) stop('not supported matrix format')
   if(dim(rgba)[1] != 4) stop('palette with 4 columns expected')
   if(dim(rgba)[2] < 2) stop('palette with at least 2 colors expected')
   
   rows <- dim(hist)[1]
   cols <- dim(hist)[2]
   size <- dim(rgba)[2]
   dim_rgbwt <- 5
   
   rgbwt <- rep(0, rows * cols * dim_rgbwt)  #initialize matrix
   
   mini <- min(hist)
   maxi <- max(hist)
   normalized_hist <- (hist - mini) / (maxi - mini)  #normalize histogram on values 0-1
   
   result <- .C("hist_colorize",
     dimen = as.integer(c(rows, cols, size)),
     rgbwt = as.single(rgbwt),
     rgba = as.single(rgba / 255),
     normalized_hist = as.single(normalized_hist))
     

   rgbwt <- array(as.single(result$rgbwt), c(rows, cols, dim_rgbwt))
   return(rgbwt)
}
