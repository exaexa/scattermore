# This file is part of scattermore.
#
# Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
#               2022 Tereza Kulichova <kulichova.t@gmail.com>
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

#' scatter_histogram
#'
#' Create histogram from given point coordinates.
#'
#' @param xy Vector with 4 elements or matrix or array (4xn dim, n >= 2, n ~ xy rows)
#'           with the line's begin and start point, for vector format is
#'           `(x_begin, y_begin, x_end, y_end)`, for matrices similarly. As usual with
#'           rasters in R, X axis grows right, and Y axis grows DOWN.
#'           Flipping `ylim` causes the "usual" mathematical behavior.
#'
#' @param xlim Limits as usual (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom), 2-element vector.
#'                   You can easily flip the top/bottom to the "usual" mathematical
#'                   system by flipping the `ylim` vector.
#'
#' @param ylim Limits as usual (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom), 2-element vector.
#'                   You can easily flip the top/bottom to the "usual" mathematical
#'                   system by flipping the `ylim` vector.
#'
#' @param out_size 2-element vector size of the result raster,
#'                 defaults to `c(512,512)`.
#'
#' @param RGBA Vector with 4 elements or matrix or array (4xn dim, n >= 2, n ~ xy rows) with R, G, B
#'             and alpha channels in integers, defaults to `c(0,0,0,255)`.
#'
#' @return An array in RGBWT format with the scatterplot output.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
draw_lines <- function(xy,
                       xlim = c(min(xy), max(xy)),
                       ylim = c(min(xy), max(xy)),
                       out_size = c(512, 512),
                       RGBA = c(0, 0, 0, 255)) {
  if (!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size) || !is.vector(RGBA)) stop("vector input in parameters xlim, ylim, out_size or RGBA expected")
  if (length(RGBA) != scattermore.globals$dim_RGBA) stop("RGBA vector of length 4 expected")

  if (is.vector(xy) && length(xy) == 4) n <- 1
  else if ((is.matrix(xy) || is.array(xy)) && dim(xy)[2] == 4) n <- dim(xy)[1]
  else stop("xy vector of length 4 expected or xy matrix with 4 rows expected")

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  RGBWT <- array(0, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  RGBWT[, , scattermore.globals$T] <- 1 # initialize transparency (multiplying)

  result <- .C("draw_lines",
    xy = as.single(xy),
    dimen = as.integer(c(size_x, size_y, n)),
    xlim = as.single(xlim),
    ylim = as.single(ylim),
    RGBA = as.single(RGBA / 255),
    fRGBWT = as.single(RGBWT)
  )

  fRGBWT <- array(result$fRGBWT, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  return(fRGBWT)
}
