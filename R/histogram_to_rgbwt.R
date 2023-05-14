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

#' histogram_to_rgbwt
#'
#' Colorize given histogram with input palette.
#'
#' @param fhistogram Matrix or 2D array with the histogram of values.
#'
#' @param RGBA 4-by-N matrix floating-point R, G, B and A channels for the palette. Overrides `col`.
#'
#' @param col Colors to use for coloring.
#'
#' @param zlim Values to use as extreme values of the histogram
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

histogram_to_rgbwt <- function(fhistogram,
                               RGBA = col2rgb(col, alpha = T),
                               col = c("white", "black"),
                               zlim = c(min(fhistogram), max(fhistogram))) {
  if (!is.matrix(fhistogram) && !is.array(fhistogram)) stop("unsupported histogram format")
  if (length(dim(fhistogram)) != 2) stop("unsupported histogram format")
  if (dim(RGBA)[1] != 4) stop("RGBA with 4 rows expected")
  if (dim(RGBA)[2] < 2) stop("at least 2-color palette is required")

  rows <- dim(fhistogram)[1]
  cols <- dim(fhistogram)[2]
  pal_size <- dim(RGBA)[2]

  RGBWT <- array(0, c(rows, cols, 5))

  normalized_fhistogram <- pmin(pal_size, pmax(
    0,
    pal_size * (fhistogram - zlim[1]) / max((zlim[2] - zlim[1]), scattermore.globals$epsilon)
  ))

  result <- .C("histogram_to_rgbwt",
    dimen = as.integer(c(rows, cols, pal_size)),
    fRGBWT = as.single(RGBWT),
    RGBA = as.single(RGBA / 255),
    normalized_fhistogram = as.integer(normalized_fhistogram)
  )

  return(array(result$fRGBWT, c(rows, cols, 5)))
}
