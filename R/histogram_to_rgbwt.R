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

#' histogram_to_rgbwt
#'
#' Colorize given histogram with input palette.
#'
#' @param fhistogram Matrix or array R datatype interpreted as histogram.
#'
#' @param RGBA matrix (4xn dim, n>= 2) with R, G, B and alpha channels
#'             in integers, defaults to shades of `red`, `green` and `blue` with `alpha = 255`.
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

histogram_to_rgbwt <- function(fhistogram,
                               RGBA = array(c(250, 128, 114, 255, 144, 238, 144, 255, 176, 224, 230, 255), c(4, 3))) {
  if (!is.matrix(fhistogram) && !is.array(fhistogram)) stop("fhistogram in matrix form expected")
  if (dim(fhistogram)[2] < 2) stop("not fhistogram format")
  if (dim(RGBA)[1] != scattermore.globals$dim_RGBA) stop("RGBA with 4 rows expected")
  if (dim(RGBA)[2] < 2) stop("RGBA with at least 2 colors expected")

  rows <- dim(fhistogram)[1]
  cols <- dim(fhistogram)[2]
  size <- dim(RGBA)[2]

  RGBWT <- rep(0, rows * cols * scattermore.globals$dim_RGBWT)

  minimum <- min(fhistogram)
  maximum <- max(fhistogram)
  # normalize histogram on values 0-1
  normalized_fhistogram <- (fhistogram - minimum) / max((maximum - minimum), scattermore.globals$epsilon)

  result <- .C("histogram_to_rgbwt",
    dimen = as.integer(c(rows, cols, size)),
    fRGBWT = as.single(RGBWT),
    RGBA = as.single(RGBA / 255),
    normalized_fhistogram = as.single(normalized_fhistogram)
  )


  fRGBWT <- array(result$fRGBWT, c(rows, cols, scattermore.globals$dim_RGBWT))
  return(fRGBWT)
}
