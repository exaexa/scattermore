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

#' scatter_lines_rgbwt
#'
#' Render lines into a RGBWT bitmap.
#'
#' @param xy 4-column matrix with point coordinates.
#'           Each row contains X and Y coordinates of line start and X and Y coordinates of line end, in this order.
#'
#' @param xlim,ylim 2-element vector of rendered area limits (position of the first pixel on the
#'                   left/top, and the last pixel on the right/bottom).
#'                   You can flip the image coordinate system by flipping the `*lim` vectors.
#'
#' @param RGBA Vector of 4 elements with integral RGBA color for the lines, defaults to `c(0,0,0,255)`.
#'
#' @param skip_start_pixel TRUE if the start pixel of the lines should be omitted, defaults to `FALSE`.
#'
#' @param skip_end_pixel TRUE if the end pixel of a line should be omitted, defaults to `TRUE`.
#'                       (When plotting long ribbons of connected lines, this prevents counting the connecting pixels twice.)
#'
#' @return Lines plotted in RGBWT bitmap.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

scatter_lines_rgbwt <- function(xy,
                                xlim = c(min(xy[,c(1,3)]), max(xy[,c(1,3)])),
                                ylim = c(min(xy[,c(2,4)]), max(xy[,c(2,4)])),
                                out_size = c(512L, 512L),
                                RGBA = c(0, 0, 0, 255),
                                skip_start_pixel = FALSE,
                                skip_end_pixel = TRUE) {
  if (!is.numeric(xlim) || length(xlim) != 2) stop("invalid xlim")
  if (!is.numeric(ylim) || length(ylim) != 2) stop("invalid ylim")
  if (!is.numeric(out_size) || length(out_size) != 2) stop("invalid out_size")

  n <- if ((is.matrix(xy) || is.array(xy)) && dim(xy)[2] == 4) dim(xy)[1]
       else stop("invalid line coordinates in xy (expected 4-column matrix)")

  if (!is.numeric(RGBA) || length(RGBA) != 4) stop("invalid RGBA")

  size_x <- as.integer(out_size[1])
  size_y <- as.integer(out_size[2])

  RGBWT <- array(0, c(size_y, size_x, 5))
  RGBWT[, , 5] <- 1 # initialize the transparency (multiplicative)

  result <- .C("scatter_lines_rgbwt",
    xy = as.single(xy),
    dimen = as.integer(c(size_x, size_y, n)),
    xlim = as.single(xlim),
    ylim = as.single(ylim),
    RGBA = as.single(RGBA / 255),
    skip_pixel = as.integer(c(skip_start_pixel, skip_end_pixel)),
    fRGBWT = as.single(RGBWT)
  )

  return(array(result$fRGBWT, c(size_y, size_x, 5)))
}
