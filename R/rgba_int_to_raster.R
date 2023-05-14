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

#' rgba_int_to_raster
#'
#' Create a raster from the given RGBA matrix.
#'
#' @param i32RGBA Integer RGBA matrix (with all values between 0 and 255).
#'
#' @return The matrix converted to raster.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
#' @importFrom grDevices as.raster

rgba_int_to_raster <- function(i32RGBA) {
  if (!is.array(i32RGBA) || dim(i32RGBA)[3] != 4) stop("unsupported i32RGBA format")

  return(grDevices::as.raster(i32RGBA, max = 255))
}
