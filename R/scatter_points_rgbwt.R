#' scatter_points_rgbwt
#'
#' Colorize given data with one given color or each point has its corresponding given color.
#'
#' @param xy 2-column matrix with point coordinates. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the "usual" mathematical behavior.
#'
#' @param xlim Limits as usual (position of the first pixel on the
#'             left/top, and the last pixel on the right/bottom), 2-element vector.
#'             You can easily flip the top/bottom to the "usual" mathematical
#'             system by flipping the `ylim` vector.
#'
#' @param ylim Limits as usual (position of the first pixel on the
#'             left/top, and the last pixel on the right/bottom), 2-element vector.
#'             You can easily flip the top/bottom to the "usual" mathematical
#'             system by flipping the `ylim` vector.
#'
#' @param out_size 2-element vector, size of the result histogram,
#'                 defaults to `c(512,512)`.
#'
#' @param RGBA Vector with 4 elements or matrix or array (4xn dim, n >= 2, n ~ xy rows) with R, G, B
#'             and alpha channels  in integers, defaults to `c(0,0,0,255)`.
#'
#' @param map Vector with indices to `palette`.
#'
#' @param palette Matrix or array (4xn dim, n >= 2, n ~ xy rows) with R, G, B and alpha channels  in integers.
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
scatter_points_rgbwt <- function(
  xy,
  xlim = c(min(xy[,1]),max(xy[,1])),
  ylim = c(min(xy[,2]),max(xy[,2])),
  out_size = c(512,512),
  RGBA = c(0,0,0,255),
  map = NULL,
  palette = NULL)
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')

   if(!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size)) stop('vector input in parameters xlim, ylim or out_size expected')

   dim_color <- 4
   if(is.vector(map))
   {
   	if(length(map) != n) stop('map with the same data count as xy expected')
   	if(!is.matrix(palette) && !is.array(palette)) stop('not supported palette format')
   	if(dim(palette)[1] != dim_color) stop('palette with 4 rows expected')
   	id <- 1
   }
   else if(is.vector(RGBA))
   {
   	if(length(RGBA) != dim_color) stop('RGBA vector of length 4 expected')
   	id <- 2
   }
   else if(is.matrix(RGBA) || is.array(RGBA))
   {
	if(dim(RGBA)[1] != dim_color) stop('RGBA matrix with 4 rows expected')
	if(dim(RGBA)[2] != n) stop('incorrect number of colors parameter RGBA')
	id <- 3
   }
   else stop('unsupported input')


   rows <- out_size[1]
   cols <- out_size[2]
   dim_RGBWT <- 5

   RGBWT <- array(0, c(rows, cols, dim_RGBWT))
   RGBWT[,,5] <- 1  #initialize transparency (multiplying)

   if(id == 1)                  #colorize using palette
   {
     result <- .C("scatter_indexed_rgbwt",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       palette = as.single(palette / 255),
       fRGBWT = as.single(RGBWT),
       map = as.integer(map),
       xy = as.single(xy))
   }
   else if(id == 2)            #colorize with one color
   {
     result <- .C("scatter_singlecolor_rgbwt",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       RGBA = as.single(RGBA / 255),
       fRGBWT = as.single(RGBWT),
       xy = as.single(xy))
   }
   else
   {                           #colorize with given color for each point
     result <- .C("scatter_multicolor_rgbwt",
       dimen = as.integer(c(rows, cols, n)),
       xlim = as.single(xlim),
       ylim = as.single(ylim),
       RGBA = as.single(RGBA / 255),
       fRGBWT = as.single(RGBWT),
       xy = as.single(xy))
   }

    fRGBWT <- array(result$fRGBWT, c(rows, cols, dim_RGBWT))
    return(fRGBWT)
}
