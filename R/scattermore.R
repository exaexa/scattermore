
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
#' @param x,y,xlim,ylim,xlab,ylab,... used as in plot() or forwarded to plot()
#' @param col point color(s)
#' @param cex forwarded to scattermore()
#' @param size forwarded to scattermore(), or auto-derived from device and plot size if missing (the estimate is not pixel-perfect, but pretty close)
#' @examples
#' library(scattermore)
#' scattermoreplot(
#'   rnorm(1e7),
#'   rnorm(1e7),
#'   col=heat.colors(1e7, alpha=.1),
#'   main="scattermore demo")
#' @export
scattermoreplot <- function(
  x,
  y,
  xlim,
  ylim,
  size,
  col=rgb(0,0,0,1),
  cex=0,
  xlab,
  ylab,
  ...)
{
  if(missing(x)) stop("Supply at least one vector")
  if(!missing(y)) x <- matrix(ncol=2,c(x,y))

  if(missing(xlim)) xlim <- c(min(x[,1]),max(x[,1]))
  if(missing(ylim)) ylim <- c(min(x[,2]),max(x[,2]))

  xlab <- if(!missing(xlab)) xlab else if(!is.null(colnames(x))) colnames(x)[1] else "X"
  ylab <- if(!missing(ylab)) ylab else if(!is.null(colnames(x))) colnames(x)[2] else "Y"

  plot(x[1,], pch='', xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab, ...)
  usr <- par('usr')
  if(missing(size)) size <- as.integer(dev.size('px')/dev.size('in')*par('pin'))
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

# Internally used utility for naming grobs
ggname <- function(p, g) {
  g$name <- grid::grobName(g, p)
  g
}

#' geom_scattermore
#' 
#' `ggplot2` integration. This is nice and cooperates with the rest of ggplot (so
#' you can use it to e.g. add rasterized scatterplots to vector output in order
#' to reduce PDF size), but the ggplot processing overhead still dominates the
#' whole processing time. Use `geom_scattermost` to tradeoff some niceness and
#' circumvent ggplot logic to gain speed.
#'
#' Accepts aesthetics `x`, `y`, `colour` and `alpha`. Point size is fixed for
#' all points. Due to rasterization properties it is often beneficial to try
#' non-integer point sizes, e.g. `3.2` looks much better than `3`.
#'
#' @inheritParams ggplot2::layer
#'
#' @param na.rm Remove NA values, just as with `geom_point`.
#' @param ... Passed to `layer`.
#' @param interpolate Default FALSE, passed to `rasterGrob`.
#' @param pointsize Radius of rasterized point. Use `0` for single pixels (fastest).
#' @param pixels Vector with X and Y resolution of the raster, default `c(512,512)`.
#' @examples
#' library(ggplot2)
#' library(scattermore)
#' ggplot(data.frame(x=rnorm(100000), y=rexp(100000))) +
#'   geom_scattermore(aes(x,y,color=x),
#'                    pointsize=2.5,
#'                    alpha=0.3,
#'                    pixels=c(1000,1000),
#'                    interpolate=T) +
#'   scale_color_viridis_d()
#' @export
geom_scattermore <- function(
  mapping=NULL, data=NULL, stat="identity", position="identity", ...,
  na.rm=FALSE, show.legend = NA, inherit.aes = TRUE,
  interpolate = FALSE, pointsize = 0, pixels=c(512,512)) {

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    position = position,
    geom = GeomScattermore,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      interpolate = interpolate,
      pointsize = pointsize,
      pixels=pixels,
      ...
    )
  )
}

GeomScattermore <- ggplot2::ggproto("GeomScattermore", ggplot2::Geom,
  required_aes = c("x", "y"),
  non_missing_aes = c("alpha", "colour"),
  default_aes = ggplot2::aes(
    shape = NA, colour = "black", size = 1.5, fill = NA,
    alpha = 1, stroke = 0.5
  ),

  draw_panel = function(data, pp, coord,
                        pointsize = 0, interpolate = F,
                        na.rm = FALSE, pixels=c(512,512)) {
    coords <- coord$transform(data, pp)

    ggname("geom_scattermore",
      grid::rasterGrob(
        scattermore(
          cbind(coords$x, coords$y),
          rgba=grDevices::col2rgb(alpha=T, alpha(coords$colour, coords$alpha)),
          cex=pointsize,
          xlim=c(0,1),
          ylim=c(0,1),
          size=pixels
        ),
        0,0,1,1,
        default.units='native',
        just=c('left','bottom'),
        interpolate=interpolate
      )
    )
  },

  draw_key = ggplot2::draw_key_point
)

#' geom_scattermost
#'
#' Totally non-ggplotish version of `geom_scattermore`, but faster. It avoids
#' most of the ggplot processing by bypassing the largest portion of data
#' around any ggplot functionality, leaving only enough data to set up axes and
#' limits correctly. If you need to break speed records, use this.
#'
#' @param xy 2-column object with data, as in `scattermore`.
#' @param color Color vector (or a single color).
#' @param interpolate Default FALSE, passed to `rasterGrob`.
#' @param pointsize Radius of rasterized point. Use `0` for single pixels (fastest).
#' @param pixels Vector with X and Y resolution of the raster, default `c(512,512)`.
#' @examples
#' library(ggplot2)
#' library(scattermore)
#' d <- data.frame(x=rnorm(1000000), y=rnorm(1000000))
#' x_rng <- range(d$x)
#' ggplot() +
#'   geom_scattermost(cbind(d$x,d$y),
#'                    color=heat.colors(100, alpha=.3)
#'                          [1+99*(d$x-x_rng[1])/diff(x_rng)],
#'                    pointsize=2.5,
#'                    pixels=c(1000,1000),
#'                    interpolate=T)
#' @export
geom_scattermost <- function(
  xy,
  color = "black",
  interpolate = FALSE,
  pointsize = 0,
  pixels=c(512,512)) {

  ggplot2::layer(
    data =
      data.frame(x=c(min(xy[,1]),max(xy[,1])),
                 y=c(min(xy[,2]),max(xy[,2]))),
    mapping = ggplot2::aes_string(x="x",y="y"),
    stat = 'identity',
    position = 'identity',
    geom = GeomScattermost,
    show.legend = NA,
    params = list(
      interpolate = interpolate,
      pointsize = pointsize,
      xy = xy,
      co = color,
      pixels=pixels
    )
  )
}

GeomScattermost <- ggplot2::ggproto("GeomScattermost", ggplot2::Geom,
  required_aes = c("x", "y"),

  draw_panel = function(data, pp, coord,
                        pointsize = 0,
                        interpolate = F,
                        xy,
                        co="black",
                        pixels=c(512,512)) {
    coords <- coord$transform(data.frame(x=xy[,1],y=xy[,2]),pp)

    ggname("geom_scattermost",
      grid::rasterGrob(
        scattermore(cbind(coords$x, coords$y),
          cex=pointsize,
          rgba=grDevices::col2rgb(alpha=T, co),
          xlim=c(0,1),
          ylim=c(0,1),
          size=pixels
        ),
        0,0,1,1,
        default.units='native',
        just=c('left','bottom'),
        interpolate=interpolate
      )
    )
  },

  draw_key = ggplot2::draw_key_point
)
