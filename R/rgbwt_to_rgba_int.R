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

#' rgbwt_to_rgba_int
#'
#' Convert RGBWT matrix to integer RGBA matrix.
#'
#' @param fRGBWT fRGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#' @return RGBA matrix, output *is not premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

rgbwt_to_rgba_int <- function(fRGBWT) {
  if (!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop("not supported fRGBWT format")

  rows <- dim(fRGBWT)[1]
  cols <- dim(fRGBWT)[2]

  W <- 255 / pmax(scattermore.globals$epsilon, fRGBWT[, , scattermore.globals$W])

  i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
  i32RGBA[, , scattermore.globals$R] <- as.integer(fRGBWT[, , scattermore.globals$R] * W)
  i32RGBA[, , scattermore.globals$G] <- as.integer(fRGBWT[, , scattermore.globals$G] * W)
  i32RGBA[, , scattermore.globals$B] <- as.integer(fRGBWT[, , scattermore.globals$B] * W)
  i32RGBA[, , scattermore.globals$A] <- as.integer(255 * (1 - fRGBWT[, , scattermore.globals$T]))

  return(i32RGBA)
}
