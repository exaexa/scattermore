
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
#' @param output.raster Output R-style raster (as.raster)? Default TRUE. Raw
#'                      array output can be used much faster,
#'                      e.g. in png::writePNG.
#' @return Raster with the result.
#'
#' @useDynLib scattermore, .registration = TRUE
#' @examples
#' library(scattermore)
#' plot(scattermore(cbind(rnorm(1e7),rnorm(1e7)), rgba=c(64,128,192,10)))
#' @export
scattermore <- function(
  xy,
  size=c(512,512),
  xlim=c(min(xy[,1]),max(xy[,1])),
  ylim=c(min(xy[,2]),max(xy[,2])),
  rgba=c(0L,0L,0L,255L),
  cex=0,
  output.raster=T)
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

  if(output.raster) as.raster(array(res$rd,c(size[2],size[1],4)), max=255L)
  else array(res$rd,c(size[2],size[1],4))
}

#' scattermoreplot
#'
#' Convenience base-graphics-like layer around scattermore. Currently only works with linear axes!
#'
#' @param x,y,xlim,ylim,... used as in plot() or forwarded to plot()
#' @param col point color(s)
#' @param cex forwarded to scattermore()
#' @param size forwarded to scattermore(), or auto-derived from device and plot size if missing (the estimate is not pixel-perfect, but pretty close)
#' @examples
#' library(scattermore)
#' scattermoreplot(rnorm(1e7), rnorm(1e7), col=heat.colors(1e7, alpha=.1))
#' @export
scattermoreplot <- function(
  x,
  y,
  xlim,
  ylim,
  size,
  col=rgb(0,0,0,1),
  cex=0, ...)
{
  if(missing(x)) stop("Supply at least one vector")
  if(!missing(y)) x <- cbind(x,y)

  if(missing(xlim)) xlim <- c(min(x[,1]),max(x[,1]))
  if(missing(ylim)) ylim <- c(min(x[,2]),max(x[,2]))

  plot(x[1,], pch='', xlim=xlim, ylim=ylim, ...)
  usr <- par('usr')
  if(missing(size)) size <- as.integer(dev.size('px')/par('fin')*par('pin'))
  rasterImage(
    scattermore(
      x,
      size=size,
      xlim=usr[1:2],
      ylim=usr[3:4],
      cex=cex,
      rgba=col2rgb(col, alpha=T),
      output.raster=T),
    xleft=usr[1],
    xright=usr[2],
    ybottom=usr[3],
    ytop=usr[4],
  )
}
