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

#' rgba_float_to_rgba_int
#'
#' Convert RGBA matrix to RGBA matrix.
#'
#' @param fRGBA RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @return RGBA matrix, output *is not premultiplied* by alpha.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
rgba_float_to_rgba_int <- function(fRGBA) {
  if (!is.array(fRGBA) || dim(fRGBA)[3] != scattermore.globals$dim_RGBA) stop("not supported fRGBA format")

  rows <- dim(fRGBA)[1]
  cols <- dim(fRGBA)[2]

  A <- 255 / pmax(scattermore.globals$epsilon, fRGBA[, , scattermore.globals$A]) # "unpremultiply" alpha

  i32RGBA <- array(0, c(rows, cols, scattermore.globals$dim_RGBA))
  i32RGBA[, , scattermore.globals$R] <- as.integer(fRGBA[, , scattermore.globals$R] * A)
  i32RGBA[, , scattermore.globals$G] <- as.integer(fRGBA[, , scattermore.globals$G] * A)
  i32RGBA[, , scattermore.globals$B] <- as.integer(fRGBA[, , scattermore.globals$B] * A)
  i32RGBA[, , scattermore.globals$A] <- as.integer(255 * fRGBA[, , scattermore.globals$A])

  return(i32RGBA)
}
