#' colorize_hist
#'
#' Colorize given histogram with input palette.
#'
#' @param hist matrix or array R datatype interpreted as histogram
#'
#' @param pallete matrix (4xn dim, n>= 2) with R, G, B and alpha channels 
#'                in integers, defaults to shades of `red`, `green` and `white` with `alpha = 255`
#'
#' @return float matrix with the result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
colorize_hist <- function(
  hist,
  palette = array(c(250,128,114,255,144,238,144,255,176,224,230,255), c(4,3)))
{
   rows = dim(hist)[1]
   cols = dim(hist)[2]
   size = dim(palette)[2]
   
   if(!is.matrix(hist)) stop('histogram in matrix form expected')
   if(dim(palette)[1] != 4) stop('palette with 4 columns expected')
   if(size < 2) stop('palette with at least 2 colors expected')
   
   matrix <- rep(0, rows * cols * 4)
   normalized_hist = (hist - min(hist)) / (max(hist) - min(hist))
   
   result <- .C("hist_colorize",
     dimen = as.integer(c(rows, cols, size)),
     matrix = as.integer(matrix),
     palette = as.integer(palette),
     normalized_hist = as.single(normalized_hist))

    colorized_hist = array(result$matrix, c(rows, cols, 4))
    return(grDevices::as.raster(colorized_hist, max = 255))
}
