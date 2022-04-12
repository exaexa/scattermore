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

#' merge_rgbwt
#'
#' Merge two RGBWT matrices.
#'
#' @param fRGBWT_1 RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                               `transparency` ~ 1 - alpha, dimension nxmx5).
#'
#' @param fRGBWT_2 The same as fRGBWT_1 parameter.
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
merge_rgbwt <- function(fRGBWT_1, fRGBWT_2) {
  if (!is.array(fRGBWT_1) || dim(fRGBWT_1)[3] != scattermore.globals$dim_RGBWT) stop("not supported fRGBWT_1 format")
  if (!is.array(fRGBWT_2) || dim(fRGBWT_2)[3] != scattermore.globals$dim_RGBWT) stop("not supported fRGBWT_2 format")
  if ((dim(fRGBWT_1)[1] != dim(fRGBWT_2)[1]) || (dim(fRGBWT_1)[2] != dim(fRGBWT_2)[2])) stop("parameters do not have same dimensions")

  rows <- dim(fRGBWT_1)[1]
  cols <- dim(fRGBWT_1)[2]

  fRGBWT <- array(0, c(rows, cols, scattermore.globals$dim_RGBWT))
  fRGBWT[, , 1:4] <- fRGBWT_1[, , 1:4] + fRGBWT_2[, , 1:4] # merge
  fRGBWT[, , scattermore.globals$T] <- fRGBWT_1[, , scattermore.globals$T] * fRGBWT_2[, , scattermore.globals$T]

  return(fRGBWT)
}
