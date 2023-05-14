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
#' Render colored points into a RGBWT bitmap
#'
#' @param xy 2-column matrix with N point coordinates (X and Y) in rows.
#'
#' @param xlim,ylim 2-element vector of rendered area limits (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom).
#'                   You can flip the image coordinate system by flipping the `*lim` vectors.
#'
#' @param out_size 2-element vector size of the result raster, defaults to `c(512L,512L)`.
#'
#' @param RGBA Point colors. Either a 4-element vector that specifies the same color for all points,
#'             or 4-by-N matrix that specifies color for each of the individual points.
#'             Color is specified using integer RGBA; i.e. the default black is `c(0,0,0,255)`.
#'
#' @param map Vector with N integer indices to `palette`. Overrides RGBA-based coloring.
#'
#' @param palette Matrix 4-by-K matrix of RGBA colors used as a palette lookup for the `map`
#'                that gives the point colors. K is at least `maximum(map)`.
#'                Notably, using a palette may be faster than filling and processing the whole RGBA matrix.
#'
#' @return A RGBWT array with the rendered points.
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
  if (!is.numeric(xlim) || length(xlim) != 2) stop("invalid xlim")
  if (!is.numeric(ylim) || length(ylim) != 2) stop("invalid ylim")
  if (!is.numeric(out_size) || length(out_size) != 2) stop("invalid out_size")

  if (dim(xy)[2] != 2) stop("2-column xy input expected")
  n <- dim(xy)[1]

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  RGBWT <- array(0, c(size_y, size_x, 5))
  RGBWT[, , 5] <- 1 # initialize transparency (multiplying)

  result <- if (is.numeric(map)) {
    map <- as.integer(map) - 1L
    if (length(map) != n) stop("wrong size of map")
    if (any(map < 0L)) stop("indices in map must start from 1")
    if (!is.matrix(palette) && !is.array(palette)) stop("unsupported palette format")
    if (dim(palette)[1] != 4) stop("unsupported palette format")
    if (maximum(map) >= dim(palette)[2]) stop("map indices too high for this palette")
    .C("scatter_indexed_rgbwt",
      dimen = as.integer(c(size_x, size_y, n)),
      xlim = as.single(xlim),
      ylim = as.single(ylim),
      palette = as.single(palette / 255),
      fRGBWT = as.single(RGBWT),
      map = as.integer(map),
      xy = as.single(xy)
    )
  } else if (is.vector(RGBA) || ((is.matrix(RGBA) || is.array(RGBA)) && dim(RGBA)[2] == 1)) {
    if (length(RGBA) != 4) stop("RGBA vector of length 4 expected")
    .C("scatter_singlecolor_rgbwt",
      dimen = as.integer(c(size_x, size_y, n)),
      xlim = as.single(xlim),
      ylim = as.single(ylim),
      RGBA = as.single(RGBA / 255),
      fRGBWT = as.single(RGBWT),
      xy = as.single(xy)
    )
  } else if (is.matrix(RGBA) || is.array(RGBA)) {
    if (dim(RGBA)[1] != 4) stop("RGBA matrix with 4 rows expected")
    if (dim(RGBA)[2] == n) {
      .C("scatter_multicolor_rgbwt",
        dimen = as.integer(c(size_x, size_y, n)),
        xlim = as.single(xlim),
        ylim = as.single(ylim),
        RGBA = as.single(RGBA / 255),
        fRGBWT = as.single(RGBWT),
        xy = as.single(xy)
      )
    } else {
      stop("incorrect number of colors in RGBA")
    }
  } else {
    stop("unsupported coloring type")
  }

  return(array(result$fRGBWT, c(size_y, size_x, 5)))
}
