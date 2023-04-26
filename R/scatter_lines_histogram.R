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

#' scatter_lines_histogram
#'
#' Create histogram using lines with given start and end points.
#'
#' @param xy 4-column matrix with point coordinates. Format is
#'           `(x_begin, y_begin, x_end, y_end)`. As usual with
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
#' @param skip_start_pixel TRUE if the start pixel of a line should not be plotted,
#'                         otherwise 'FALSE', defaults to `FALSE`.
#'
#' @param skip_end_pixel TRUE if the end pixel of a line should not be plotted,
#'                       otherwise 'FALSE', defaults to `TRUE`.
#'
#' @return Histogram with the result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

scatter_lines_histogram <- function(xy,
                                    xlim = c(min(xy[,c(1,3)]), max(xy[,c(1,3)])),
                                    ylim = c(min(xy[,c(2,4)]), max(xy[,c(2,4)])),
                                    out_size = c(512, 512),
                                    skip_start_pixel = FALSE,
                                    skip_end_pixel = TRUE) {
  if (!is.vector(xlim) || !is.vector(ylim) || !is.vector(out_size)) stop("vector input in parameters xlim, ylim or out_size expected")

  if (is.vector(xy) && length(xy) == scattermore.globals$length_xy_lines) n <- 1
  else if ((is.matrix(xy) || is.array(xy)) && dim(xy)[2] == scattermore.globals$length_xy_lines) n <- dim(xy)[1]
  else stop("xy vector of length 4 expected or xy matrix with 4 columns expected")

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  result <- .C("scatter_lines_histogram",
    xy = as.single(xy),
    dimen = as.integer(c(size_x, size_y, n)),
    xlim = as.single(xlim),
    ylim = as.single(ylim),
    skip_pixel = as.integer(c(skip_start_pixel, skip_end_pixel)),
    i32histogram = integer(size_x * size_y)
  )

  fhistogram <- array(result$i32histogram, c(size_y, size_x))
  return(fhistogram)
}
