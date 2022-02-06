#' colorize_hist
#'
#' Colorize given histogram with input palette.
#'
#' @param hist Matrix or array R datatype interpreted as histogram.
#'
#' @param rgba Matrix (4xn dim, n>= 2) with R, G, B and alpha channels 
#'             in integers, defaults to shades of `red`, `green` and `blue` with `alpha = 255`.
#'
#' @return Raster or integer matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
colorize_hist <- function(
  hist,
  rgba = array(c(250,128,114,255,144,238,144,255,176,224,230,255), c(4,3)),
  output_raster = TRUE)
{
   rows <- dim(hist)[1]
   cols <- dim(hist)[2]
   size <- dim(rgba)[2]
   dim_matrix = 4
   
   if(!is.matrix(hist)) stop('histogram in matrix form expected')
   if(dim(rgba)[1] != 4) stop('palette with 4 columns expected')
   if(size < 2) stop('palette with at least 2 colors expected')
   
   matrix <- rep(0, rows * cols * dim_matrix)
   
   mini = min(hist)
   maxi = max(hist)
   normalized_hist = (hist - mini) / (maxi - mini)
   
   result <- .C("hist_colorize",
     dimen = as.integer(c(rows, cols, size)),
     matrix = as.integer(matrix),
     rgba = as.integer(rgba),
     normalized_hist = as.single(normalized_hist))

    colorized_hist = array(result$matrix, c(rows, cols, dim_matrix))
   if(output_raster) return(grDevices::as.raster(colorized_hist, max = 255)) else return(colorized_hist)
}
