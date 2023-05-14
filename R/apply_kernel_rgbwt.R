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

#' apply_kernel_rgbwt
#'
#' Apply a kernel to the given RGBWT raster.
#'
#' @param fRGBWT RGBWT array with channels `red`, `green`, `blue`, `weight` and `transparency`. The dimension should be N times M times 5.
#'
#' @param filter Use the pre-defined filter, either `circle`, `square`, `gauss`. Defaults to `circle`.
#'
#' @param mask Custom kernel used for blurring, overrides `filter`. Must be a square matrix of odd size.
#'
#' @param radius Radius of the kernel (counted without the "middle" pixel"), defaults to 2. The generated kernel matrix will be a square with (2*radius+1) pixels on each side.
#'
#' @param sigma Radius of the Gaussian function selected by `filter`, defaults to `radius/2`.
#'
#' @param threads Number of parallel threads (default 0 chooses hardware concurrency).
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_rgbwt <- function(fRGBWT,
                               filter = "circle",
                               mask = default_kernel(filter, radius, sigma),
                               radius = 2,
                               sigma = radius / 2,
                               threads = 0) {
  if (threads < 0) stop("number of threads must not be negative")

  if (!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop("bad fRGBWT format")
  size_y <- dim(fRGBWT)[1]
  size_x <- dim(fRGBWT)[2]

  blurred_fRGBWT <- array(0, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  blurred_fRGBWT[, , scattermore.globals$T] <- 1 # initialize transparency (multiplicative)

  if (!is.matrix(mask) && !is.array(mask)) stop("kernel in matrix or array form expected")
  if (dim(mask)[1] != dim(mask)[2]) stop("kernel in square matrix expected")
  if (dim(mask)[1] %% 2 == 0) stop("kernel with odd size expected")

  kernel_pixels <- floor(dim(mask)[1] / 2)

  result <- .C("kernel_rgbwt",
    dimen = as.integer(c(size_x, size_y, kernel_pixels, threads)),
    kernel = as.single(mask),
    blurred_fRGBWT = as.single(blurred_fRGBWT),
    fRGBWT = as.single(fRGBWT)
  )

  blurred_fRGBWT <- array(result$blurred_fRGBWT, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  return(blurred_fRGBWT)
}
