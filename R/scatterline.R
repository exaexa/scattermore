# This file is part of scattermore.
#
# Copyright (C) 2019-2022 Mirek Kratochvil <exa.exa@gmail.com>
#               2022-2023 Tereza Kulichova <kulichova.t@gmail.com>
#
# scattermore is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# scattermore is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with scattermore. If not, see <https://www.gnu.org/licenses/>.

#' scatterlines
#'
#' Convert points to raster line plot rather quickly. Each consecutive pair of points
#' is connected with a line.
#'
#' @param xy 2-column float matrix with point coordinates. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the usual mathematical behavior.
#'           Points will be connected with lines in the order they appear in the matrix.
#' @param size 2-element vector integer size of the result raster,
#'             defaults to `c(512,512)`.
#' @param xlim,ylim Float limits as usual (position of the first pixel on the
#'                  left/top, and the last pixel on the right/bottom). You can
#'                  easily flip the top/bottom to the "usual" mathematical
#'                  system by flipping the `ylim` vector.
#' @param rgba 4-row matrix with color values of 0-255, or just a single 4-item
#'             vector for `c(r,g,b,a)`. Best created with `col2rgb(..., alpha=TRUE)`.
#' @param cex Line width in pixels, 0=single-pixel lines (fastest)
#' @param output.raster Output R-style raster (as.raster)? Default TRUE. Raw
#'                      array output can be used much faster,
#'                      e.g. for use with png::writePNG.
#' @return Raster with the result.
#'
#' @useDynLib scattermore, .registration = TRUE
#' @examples
#' library(scattermore)
#' # Generate some sample line data
#' n <- 1e4
#' x <- 1:n
#' y <- cumsum(rnorm(n))
#' points <- cbind(x, y)
#' plot(scatterlines(points, rgba = c(64, 128, 192, 128)))
#' @export
#' @importFrom grDevices as.raster

scatterlines <- function(xy,
                         size = c(512, 512),
                         xlim = c(min(xy[1,]), max(xy[1,])),
                         ylim = c(min(xy[2,]), max(xy[2,])),
                         rgba = c(0L, 0L, 0L, 255L),
                         cex = 0,
                         output.raster = TRUE) {
  n <- nrow(xy)
  xy <- cbind(xy[1:(n-1), 1:2], xy[2:n, 1:2])
  # Needs to add line to keep the original number of lines (I think)
  # xy <- rbind(xy, c(NA, NA, NA, NA)) # Currently gives an error
  
  scattered <- scatter_lines_rgbwt(xy,
                                   xlim = xlim,
                                   ylim = xlim,
                                   out_size = c(512, 512),
                                   RGBA = rgba)
  #xy, out_size = size, RGBA = rgba, xlim = xlim, ylim = ylim)
  if (cex != 0) scattered <- apply_kernel_rgbwt(scattered, radius = cex)
  rgba_int <- rgbwt_to_rgba_int(scattered)
  
  if (output.raster) {
    rgba_int_to_raster(rgba_int)
  } else {
    rgba_int
  }
}

#' scatterlinesplot
#'
#' Convenience base-graphics-like layer around scatterlines for creating line plots.
#' Currently only works with linear axes! Connects points in the order they are provided.
#'
#' @param x,y,xlim,ylim,xlab,ylab,... used as in [graphics::plot()] or forwarded to [graphics::plot()]
#' @param col line color(s)
#' @param cex line width in pixels, forwarded to [scatterlines()]
#' @param pch ignored (to improve compatibility with [graphics::plot()]
#' @param size forwarded to [scatterlines()], or auto-derived from device and plot size if missing 
#'             (the estimate is not pixel-perfect on most devices, but gets pretty close)
#' @examples
#' # plot a smooth sine curve with many points
#' library(scattermore)
#' x <- seq(0, 4*pi, length.out=1e4)
#' y <- sin(x)
#' scatterlinesplot(
#'   x, y,
#'   col = "blue",
#'   cex = 1,  # line width
#'   main = "scatterlines demo"
#' )
#' @export
#' @importFrom graphics par
#' @importFrom graphics plot
#' @importFrom graphics rasterImage
#' @importFrom grDevices dev.size
#' @importFrom grDevices rgb
scatterlinesplot <- function(x, y,
                             xlim, ylim,
                             size,
                             col = grDevices::rgb(0, 0, 0, 1),
                             cex = 0,
                             pch = NULL,
                             xlab, ylab,
                             ...) {
  if (missing(x)) stop("Supply at least one vector for plotting")
  if (!missing(y)) x <- cbind(x, y)
  
  if (missing(xlim)) xlim <- c(min(x[, 1]), max(x[, 1]))
  if (missing(ylim)) ylim <- c(min(x[, 2]), max(x[, 2]))
  
  xlab <- if (!missing(xlab)) xlab else if (!is.null(colnames(x))) colnames(x)[1] else "X"
  ylab <- if (!missing(ylab)) ylab else if (!is.null(colnames(x))) colnames(x)[2] else "Y"
  
  graphics::plot(x[1, ], pch = "", xlim = xlim, ylim = ylim, xlab = xlab, ylab = ylab, ...)
  usr <- graphics::par("usr")
  if (missing(size)) {
    size <- as.integer(
      grDevices::dev.size("px") / grDevices::dev.size("in") * graphics::par("pin")
    )
  }
  graphics::rasterImage(
    scatterlines(
      x,
      size = size,
      xlim = usr[1:2],
      ylim = usr[3:4],
      cex = cex,
      rgba = grDevices::col2rgb(col, alpha = TRUE),
      output.raster = TRUE
    ),
    xleft = usr[1],
    xright = usr[2],
    ybottom = usr[3],
    ytop = usr[4],
  )
}