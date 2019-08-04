
#' scattermore
#'
#' Convert points to raster scatterplot rather quickly.
#'
#' scattermore::scattermore(cbind(rnorm(1000),rnorm(1000)))
#'
#' @param xy 2-column float matrix with point coordinates. As usual with
#'           rasters in R, 'x' axis grows right, and 'y' axis grows DOWN.
#'           Flipping `ylim` causes the usual mathematical behavior.
#' @param size 2-element vector integer size of the result raster,
#'             defaults to 512x512.
#' @param xlim,ylim Float limits as usual (position of the first pixel on the
#'                  left/top, and the last pixel on the right/bottom). You can
#'                  easily flip the top/bottom to the "usual" mathematical
#'                  system by flipping the ylim vector.
#' @param rgba 4-row matrix with color values of 0-255, or just a single 4-item
#'             vector for c(r,g,b,a). Best created with col2rgb(..., alpha=T).
#' @param cex Point radius in pixels, 0=single-pixel dots.
#' @return Raster with the result.
#'
#' @useDynLib scattermore, .registration = TRUE
#' @export
scattermore <- function(
  xy,
  size=c(512,512),
  xlim=c(min(xy[,1]),max(xy[,1])),
  ylim=c(min(xy[,2]),max(xy[,2])),
  rgba=c(0L,0L,0L,255L),
  cex=0)
{
  n <- dim(xy)[1]
  if(dim(xy)[2] != 2) stop('2-column xy input expected')

  col <- if(is.matrix(rgba)) as.integer(rgba) else rgba
  ncol <- length(col)
  if(!(ncol %in% (4*c(1,n)))) stop('unsupported rgba content')
  ncol <- ncol %/% 4L

  rd <- rep(0L,size[1]*size[2]*4)
  res <- .C("scattermore",
    n=as.integer(n),
    ncol=as.integer(ncol),
    size=as.integer(size),
    xlim=as.single(xlim),
    ylim=as.single(ylim),
    cex=as.single(cex),
    xy=as.single(xy),
    rgba=as.integer(rgba),
    rd=as.integer(rd))

  as.raster(array(res$rd,c(size[1],size[2],4)), max=255L)
}
