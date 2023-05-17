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

#' scatter_points_histogram
#'
#' Render a 2D histogram with given points
#'
#' @param xy 2-column matrix with point coordinates (X and Y).
#'
#' @param xlim,ylim 2-element vector of rendered area limits (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom).
#'                   You can flip the image coordinate system by flipping the `*lim` vectors.
#'
#' @param out_size 2-element vector size of the result raster, defaults to `c(512L,512L)`.
#'
#' @return 2D histogram with the points "counted" in appropriate pixels.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

scatter_points_histogram <- function(xy,
                                     xlim = c(min(xy[, 1]), max(xy[, 1])),
                                     ylim = c(min(xy[, 2]), max(xy[, 2])),
                                     out_size = c(512L, 512L)) {
  if (dim(xy)[2] != 2) stop("2-column xy input expected")
  n <- dim(xy)[1]

  if (!is.numeric(xlim) || length(xlim) != 2) stop("invalid xlim")
  if (!is.numeric(ylim) || length(ylim) != 2) stop("invalid ylim")
  if (!is.numeric(out_size) || length(out_size) != 2) stop("invalid out_size")

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
