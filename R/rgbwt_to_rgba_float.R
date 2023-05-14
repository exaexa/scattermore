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

#' rgbwt_to_rgba_float
#'
#' Convert RGBWT matrix to RGBA matrix.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                             `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix, output *is premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

rgbwt_to_rgba_float <- function(fRGBWT) {
  if (!is.array(fRGBWT) || dim(fRGBWT)[3] != 5) stop("not supported fRGBWT format")

  rows <- dim(fRGBWT)[1]
  cols <- dim(fRGBWT)[2]

  A <- 1 - fRGBWT[, , 5]
  W <- A / pmax(scattermore.globals$epsilon, fRGBWT[, , 4])

  fRGBA <- array(0, c(rows, cols, 4))
  fRGBA[, , 1] <- fRGBWT[, , 1] * W # we store premultiplied alpha!
  fRGBA[, , 2] <- fRGBWT[, , 2] * W
  fRGBA[, , 3] <- fRGBWT[, , 3] * W
  fRGBA[, , 4] <- A

  return(fRGBA)
}
