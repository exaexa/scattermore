# This file is part of scattermore.
#
# Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
#               2023 Tereza Kulichova <kulichova.t@gmail.com>
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
#' @param xy 2-column matrix with point coordinates. As usual with
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
#' @param out_size 2-element vector size of the result histogram,
#'                 defaults to `c(512,512)`.
#'
#' @return Histogram with the result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

scatter_histogram <- function(xy,
                              xlim = c(min(xy[, 1]), max(xy[, 1])),
                              ylim = c(min(xy[, 2]), max(xy[, 2])),
                              out_size = c(512L, 512L)) {
  n <- dim(xy)[1]
  if (dim(xy)[2] != 2) stop("2-column xy input expected")

  if (!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size)) stop("vector input in parameters xlim, ylim or out_size expected")

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  result <- .C("scatter_histogram",
    n = as.integer(n),
    out_size = as.integer(out_size),
    i32histogram = integer(size_x * size_y),
    xlim = as.single(xlim),
    ylim = as.single(ylim),
    xy = as.single(xy)
  )

  fhistogram <- array(result$i32histogram, c(size_y, size_x))
  return(fhistogram)
}
