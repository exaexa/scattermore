# This file is part of scattermore.
#
# Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
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
#'             and alpha channels in integers, defaults to `c(0,0,0,255)`.
#'
#' @param map Vector with integer indices to `palette`.
#'
#' @param palette Matrix with R, G, B and A channels in rows, of at `maximum(map)` columns.
#'
#' @return An array in RGBWT format with the scatterplot output.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

scatter_points_rgbwt <- function(xy,
                                 xlim = c(min(xy[, 1]), max(xy[, 1])),
                                 ylim = c(min(xy[, 2]), max(xy[, 2])),
                                 out_size = c(512, 512),
                                 RGBA = c(0, 0, 0, 255),
                                 map = NULL,
                                 palette = NULL) {
  n <- dim(xy)[1]
  if (dim(xy)[2] != 2) stop("2-column xy input expected")

  if (!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size)) stop("vector input in parameters xlim, ylim or out_size expected")

  if (is.vector(map)) {
    map <- as.integer(map) - 1L
    if (length(map) != n) stop("map with the same data count as xy expected")
    if (any(map < 0L)) stop("indices in map must start from 1")
    if (!is.matrix(palette) && !is.array(palette)) stop("not supported palette format")
    if (dim(palette)[1] != 4) stop("palette with 4 rows expected")
    id <- 1
  } else if (is.vector(RGBA)) {
    if (length(RGBA) != 4) stop("RGBA vector of length 4 expected")
    id <- 2
  } else if (is.matrix(RGBA) || is.array(RGBA)) {
    if (dim(RGBA)[1] != 4) stop("RGBA matrix with 4 rows expected")
    if (dim(RGBA)[2] == n) {
      id <- 3
    } else if (dim(RGBA)[2] == 1) {
      id <- 2
    } else {
      stop("incorrect number of colors in parameter RGBA")
    }
  } else {
    stop("unsupported input type")
  }

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  RGBWT <- array(0, c(size_y, size_x, 5))
  RGBWT[, , 5] <- 1 # initialize transparency (multiplying)

  if (id == 1) # colorize using palette
    {
      result <- .C("scatter_indexed_rgbwt",
        dimen = as.integer(c(size_x, size_y, n)),
        xlim = as.single(xlim),
        ylim = as.single(ylim),
        palette = as.single(palette / 255),
        fRGBWT = as.single(RGBWT),
        map = as.integer(map),
        xy = as.single(xy)
      )
    } else if (id == 2) # colorize with one color
    {
      result <- .C("scatter_singlecolor_rgbwt",
        dimen = as.integer(c(size_x, size_y, n)),
        xlim = as.single(xlim),
        ylim = as.single(ylim),
        RGBA = as.single(RGBA / 255),
        fRGBWT = as.single(RGBWT),
        xy = as.single(xy)
      )
    } else { # colorize with given color for each point
    result <- .C("scatter_multicolor_rgbwt",
      dimen = as.integer(c(size_x, size_y, n)),
      xlim = as.single(xlim),
      ylim = as.single(ylim),
      RGBA = as.single(RGBA / 255),
      fRGBWT = as.single(RGBWT),
      xy = as.single(xy)
    )
  }

  fRGBWT <- array(result$fRGBWT, c(size_y, size_x, 5))
  return(fRGBWT)
}
