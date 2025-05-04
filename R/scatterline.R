# This file is part of scattermore.
#
# Copyright (C) 2019-2022,2025 Mirek Kratochvil <exa.exa@gmail.com>
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

#' scatterline
#'
#' like [scatterlines()] but plots a single long contiuous line through all
#' points on the input, as with [graphics::lines()].
#'
#' @param xy 2-column float matrix with line segment point coordinates.
#' @param ... forwarded to [scatterlines()]
#' @return As with [scatterlines()]
#' @examples
#' library(scattermore)
#' plot(scatterline(cbind(1:1000, sin((1:1000)/100))))
#' @export
scatterline <- function(xy, ...) {
  n <- nrow(xy)
  scatterlines(cbind(xy[1:(n-1), 1], xy[1:(n-1), 2], xy[2:n, 1], xy[2:n, 2]), ...)
}

#' scatterlines
#'
#' Like [scatterline()] but plots multiple disconnected lines.
#'
#' @param xy 4-column float matrix with line endpoint coordinates (x1, y1, x2, y2).
#' @param cex additional linewidth "radius" in pixels, 0=single-pixel lines (fastest)
#' @param size,xlim,output.raster Used as with [scattermore()].
#' @param rgba Used as with [scattermore()],
#'             but only a single RGBA color can be used (in a vector of size 4).
#'             This limitation is going to be removed in a future version.
#' @return Raster with the result.
#'
#' @useDynLib scattermore, .registration = TRUE
#' @examples
#' library(scattermore)
#' plot(scatterlines(rnorm(1e3), rgba = c(64, 128, 192, 10)))
#' @export
#' @importFrom grDevices as.raster
scatterlines <- function(xy,
                        size = c(512, 512),
                        xlim = c(min(xy[, 1]), max(xy[, 1])),
                        ylim = c(min(xy[, 2]), max(xy[, 2])),
                        rgba = c(0L, 0L, 0L, 255L),
                        cex = 0,
                        output.raster = TRUE) {
  # TODO: rgba is only a single color.
  scattered <- scatter_lines_rgbwt(xy, out_size = size, RGBA = rgba, xlim = xlim, ylim = ylim)
  if (cex != 0) scattered <- apply_kernel_rgbwt(scattered, radius = cex)
  rgba_int <- rgbwt_to_rgba_int(scattered)

  if (output.raster) {
    rgba_int_to_raster(rgba_int)
  } else {
    rgba_int
  }
}

#' scatterlineplot
#' 
#' Convenience base-graphics-like layer around [scatterlines()].
#'
#' @param x,y,xlim,ylim,xlab,ylab,... used as in [graphics::plot()] or forwarded to [graphics::plot()]
#' @param col line color
#' @param cex forwarded to [scatterline()]
#' @param pch ignored (to improve compatibility with [graphics::plot()]
#' @param size forwarded to [scatterline()], or auto-derived from device and plot size if missing (the estimate is not pixel-perfect on most devices, but gets pretty close)
#' @examples
#' # plot an actual rainbow
#' library(scattermore)
#' d <- data.frame(s = qlogis(1:1e6 / (1e6 + 1), 6, 0.5), t = rnorm(1e6, pi / 2, 0.5))
#' scatterlineplot(
#'   d$s * cos(d$t),
#'   d$s * sin(d$t),
#'   col = rainbow(1e6, alpha = .05)[c((9e5 + 1):1e6, 1:9e5)],
#'   main = "scatterlineplot demo"
#' )
#' @export
#' @importFrom graphics par
#' @importFrom graphics plot
#' @importFrom graphics rasterImage
#' @importFrom grDevices dev.size
#' @importFrom grDevices rgb
scatterlineplot <- function(x, y,
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
    scatterline(
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

#TODO: also needs scatterlinesplot (for multiple lines)

#TODO: the stuff below is just renamed but does the same as the pointy geoms now.

#' geom_scatterline
#'
#' [ggplot2::ggplot()] integration. This cooperates with the rest of ggplot
#' (so you can use it to e.g. add rasterized scatterplots to vector output in
#' order to reduce PDF size). Note that the ggplot processing overhead still dominates
#' the plotting time. Use [geom_scatterlinest()] to tradeoff some niceness and
#' circumvent ggplot logic to gain speed.
#'
#' Accepts aesthetics `x`, `y`, `colour` and `alpha`. Point size is fixed for
#' all points. Due to rasterization properties it is often beneficial to try
#' non-integer point sizes, e.g. `3.2` looks much better than `3`.
#'
#' @param na.rm Remove NA values, just as with [ggplot2::geom_point()].
#' @param interpolate Default FALSE, passed to [grid::rasterGrob()].
#' @param pointsize Radius of rasterized point. Use `0` for single pixels (fastest).
#' @param pixels Vector with X and Y resolution of the raster, default `c(512,512)`.
#' @param mapping,data,stat,position,inherit.aes,show.legend,... passed to [ggplot2::layer()]
#' @examples
#' library(ggplot2)
#' library(scattermore)
#' ggplot(data.frame(x = rnorm(1e6), y = rexp(1e6))) +
#'   geom_scatterline(aes(x, y, color = x),
#'     pointsize = 3,
#'     alpha = 0.1,
#'     pixels = c(1000, 1000),
#'     interpolate = TRUE
#'   ) +
#'   scale_color_viridis_c()
#' @export
#' @importFrom ggplot2 layer
geom_scatterline <- function(mapping = NULL, data = NULL, stat = "identity", position = "identity", ...,
                             na.rm = FALSE, show.legend = NA, inherit.aes = TRUE,
                             interpolate = FALSE, pointsize = 0, pixels = c(512, 512)) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    position = position,
    geom = GeomScatterline,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      interpolate = interpolate,
      pointsize = pointsize,
      pixels = pixels,
      ...
    )
  )
}

#' The actual geom for scatterline
#'
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 draw_key_point
#' @importFrom ggplot2 Geom
#' @importFrom ggplot2 ggproto
#' @importFrom grDevices col2rgb
#' @importFrom grid rasterGrob
#' @importFrom scales alpha
GeomScatterline <- ggplot2::ggproto("GeomScatterline", ggplot2::Geom,
  required_aes = c("x", "y"),
  non_missing_aes = c("alpha", "colour"),
  default_aes = ggplot2::aes(
    shape = 19, colour = "black", size = 1.5, fill = NA,
    alpha = 1, stroke = 0.5
  ),
  draw_panel = function(data, pp, coord,
                        pointsize = 0, interpolate = F,
                        na.rm = FALSE, pixels = c(512, 512)) {
    coords <- coord$transform(data, pp)

    ggplot2:::ggname(
      "geom_scatterline",
      grid::rasterGrob(
        scatterline(
          cbind(coords$x, coords$y),
          rgba = grDevices::col2rgb(alpha = TRUE, scales::alpha(coords$colour, coords$alpha)),
          cex = pointsize,
          xlim = c(0, 1),
          ylim = c(0, 1),
          size = pixels
        ),
        0, 0, 1, 1,
        default.units = "native",
        just = c("left", "bottom"),
        interpolate = interpolate
      )
    )
  },
  draw_key = ggplot2::draw_key_point
)

#' geom_scatterlinest
#'
#' Totally non-ggplotish version of [geom_scatterline()], but faster. It avoids
#' most of the ggplot processing by bypassing the largest portion of data
#' around any ggplot functionality, leaving only enough data to set up axes and
#' limits correctly. If you need to break speed records, use this.
#'
#' @param xy 2-column object with data, as in [scatterline()].
#' @param color Color vector (or a single color).
#' @param interpolate Default FALSE, passed to [grid::rasterGrob()].
#' @param pointsize Radius of rasterized point. Use `0` for single pixels (fastest).
#' @param pixels Vector with X and Y resolution of the raster, default `c(512,512)`.
#' @examples
#' library(ggplot2)
#' library(scattermore)
#' d <- data.frame(x = rnorm(1000000), y = rnorm(1000000))
#' x_rng <- range(d$x)
#' ggplot() +
#'   geom_scatterlinest(cbind(d$x, d$y),
#'     color = heat.colors(100, alpha = .01)
#'     [1 + 99 * (d$x - x_rng[1]) / diff(x_rng)],
#'     pointsize = 2.5,
#'     pixels = c(1000, 1000),
#'     interpolate = TRUE
#'   )
#' @export
#' @importFrom ggplot2 .data
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 layer
geom_scatterlinest <- function(xy,
                             color = "black",
                             interpolate = FALSE,
                             pointsize = 0,
                             pixels = c(512, 512)) {
  ggplot2::layer(
    data =
      data.frame(
        x = c(min(xy[, 1]), max(xy[, 1])),
        y = c(min(xy[, 2]), max(xy[, 2]))
      ),
    mapping = ggplot2::aes(x = .data$x, y = .data$y),
    stat = "identity",
    position = "identity",
    geom = GeomScatterlinest,
    show.legend = NA,
    params = list(
      interpolate = interpolate,
      pointsize = pointsize,
      xy = xy,
      co = color,
      pixels = pixels
    )
  )
}

#' The actual geom for scatterlinest
#'
#' @importFrom ggplot2 draw_key_point
#' @importFrom ggplot2 Geom
#' @importFrom ggplot2 ggproto
#' @importFrom grDevices col2rgb
#' @importFrom grid rasterGrob
GeomScatterlinest <- ggplot2::ggproto("GeomScatterlinest", ggplot2::Geom,
  required_aes = c("x", "y"),
  draw_panel = function(data, pp, coord,
                        pointsize = 0,
                        interpolate = F,
                        xy,
                        co = "black",
                        pixels = c(512, 512)) {
    coords <- coord$transform(data.frame(x = xy[, 1], y = xy[, 2]), pp)

    ggplot2:::ggname(
      "geom_scatterlinest",
      grid::rasterGrob(
        scatterline(cbind(coords$x, coords$y),
          cex = pointsize,
          rgba = grDevices::col2rgb(alpha = TRUE, co),
          xlim = c(0, 1),
          ylim = c(0, 1),
          size = pixels
        ),
        0, 0, 1, 1,
        default.units = "native",
        just = c("left", "bottom"),
        interpolate = interpolate
      )
    )
  },
  draw_key = ggplot2::draw_key_point
)
