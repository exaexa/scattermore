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

#' rgba_int_to_raster
#'
#' Create raster from given RGBA matrix.
#'
#' @param i32RGBA RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-255).
#'
#' @return Raster result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
#' @importFrom grDevices as.raster
rgba_int_to_raster <- function(i32RGBA) {
  if (!is.array(i32RGBA) || dim(i32RGBA)[3] != scattermore.globals$dim_RGBA) stop("not supported i32RGBA format")

  return(grDevices::as.raster(i32RGBA, max = 255))
}
