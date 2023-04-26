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

#' blend_rgba_float
#'
#' Blend RGBA matrices.
#'
#' @param fRGBA_list list of RGBA matrices (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @return RGBA matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
blend_rgba_float <- function(fRGBA_list) {
  if (length(fRGBA_list) < 2) stop("there have to be at least 2 elements in the fRGBA_list")

  fRGBA_1 = fRGBA_list[[1]]
  if (!is.array(fRGBA_1) || dim(fRGBA_1)[3] != scattermore.globals$dim_RGBA) stop("not supported RGBA format")
  for (i in 2:length(fRGBA_list)) {
    fRGBA_2 <- fRGBA_list[[i]]

    if (!is.array(fRGBA_2) || dim(fRGBA_2)[3] != scattermore.globals$dim_RGBA) stop("not supported RGBA format")
    if ((dim(fRGBA_1)[1] != dim(fRGBA_2)[1]) || (dim(fRGBA_1)[2] != dim(fRGBA_2)[2])) stop("parameters do not have same dimensions")

    rows <- dim(fRGBA_1)[1]
    cols <- dim(fRGBA_1)[2]

    A_1 <- fRGBA_1[, , scattermore.globals$A]
    A_2 <- fRGBA_2[, , scattermore.globals$A]

    fRGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
    # blend with premultiplied alpha
    fRGBA[, , scattermore.globals$R] <- fRGBA_1[, , scattermore.globals$R] + (fRGBA_2[, , scattermore.globals$R] * (1 - A_1))
    fRGBA[, , scattermore.globals$G] <- fRGBA_1[, , scattermore.globals$G] + (fRGBA_2[, , scattermore.globals$G] * (1 - A_1))
    fRGBA[, , scattermore.globals$B] <- fRGBA_1[, , scattermore.globals$B] + (fRGBA_2[, , scattermore.globals$B] * (1 - A_1))
    fRGBA[, , scattermore.globals$A] <- A_1 + (A_2 * (1 - A_1))

    fRGBA_1 <- fRGBA
  }

  return(fRGBA)
}
