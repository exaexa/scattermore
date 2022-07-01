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

#' apply_kernel_rgbwt
#'
#' Blur given RGBWT matrix using `circle` or `gauss` filtering.
#'
#' @param fRGBWT RGBWT matrix (`red`, `green`, `blue` channels, `weight` ~ sum of alphas,
#'                                   `transparency` ~ 1 - alpha, dimension nxmx5).
#'
#' @param filter Either `circle`, `square`, `gauss` or `own`, defaults to `circle.
#'
#' @param mask Own kernel used for blurring, `filter` parameter has to be set to `own`.
#'
#' @param radius Size of circle kernel, defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `radius / 2`.
#'
#' @param approx_limit Sets the size of the kernel, multiplied with `sigma`, defaults to `3.5`.
#'
#' @param threads Ensures multithreading when blurring the histogram, defaults to `1`, no (parallelization).
#'
#' @return RGBWT matrix.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_rgbwt <- function(fRGBWT,
                               filter = "circle",
                               mask,
                               radius = 2,
                               sigma = radius / 2,
                               approx_limit = 3.5,
                               threads = 1) {
  if (!is.numeric(radius) || !is.numeric(sigma) || !is.numeric(approx_limit) || length(radius) != 1 || length(sigma) != 1 || length(approx_limit) != 1) {
    stop("number in parameters radius, sigma or approx_limit expected")
  }
  if (radius <= 0) stop("positive radius expected")
  if (threads <= 0) stop("positive number of threads expected")

  if (!is.array(fRGBWT) || dim(fRGBWT)[3] != scattermore.globals$dim_RGBWT) stop("not supported fRGBWT format")
  size_y <- dim(fRGBWT)[1]
  size_x <- dim(fRGBWT)[2]

  blurred_fRGBWT <- array(0, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  blurred_fRGBWT[, , scattermore.globals$T] <- 1 # initialize transparency (multiplying)

  kernel_pixels <- ceiling(radius)
  size <- kernel_pixels * 2 + 1 # odd size

  if (filter == "circle") {
    kernel <- matrix(
      pmin(1, pmax(0, -sqrt(rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels)^2)) + radius)),
      size, size
    )
  } else if (filter == "square") {
    kernel <- rep(1, size * size)
  } else if (filter == "gauss") {
    kernel_pixels <- ceiling(sigma * approx_limit)
    size <- kernel_pixels * 2 + 1
    kernel <- matrix(
      exp(
        -rowSums(expand.grid(-kernel_pixels:kernel_pixels, -kernel_pixels:kernel_pixels)^2)
        / (sigma^2)
      ),
      size, size
    )
  } else if (filter == "own") {
    if (!is.matrix(mask) && !is.array(mask)) stop("kernel in matrix or array form expected")
    if (dim(mask)[1] != dim(mask)[2]) stop("kernel in square matrix expected")
    if (dim(mask)[1] %% 2 == 0) stop("kernel with odd size expected")

    kernel <- mask
    kernel_pixels <- floor(dim(kernel)[1] / 2)
  } else {
    stop("unsupported kernel shape")
  }


  result <- .C("kernel_rgbwt",
    dimen = as.integer(c(size_x, size_y, kernel_pixels, threads)),
    kernel = as.single(kernel),
    blurred_fRGBWT = as.single(blurred_fRGBWT),
    fRGBWT = as.single(fRGBWT)
  )

  blurred_fRGBWT <- array(result$blurred_fRGBWT, c(size_y, size_x, scattermore.globals$dim_RGBWT))
  return(blurred_fRGBWT)
}
