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

#' apply_kernel_histogram
#'
#' Apply a kernel to the given histogram.
#'
#' @param fhistogram Matrix or array interpreted as histogram of floating-point values.
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
#' @return 2D matrix with the histogram processed by the kernel application.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
apply_kernel_histogram <- function(fhistogram,
                                   filter = "circle",
                                   mask = default_kernel(filter, radius, sigma),
                                   radius = 2,
                                   sigma = radius / 2,
                                   threads = 0) {
  if (!is.matrix(fhistogram) && !is.array(fhistogram)) stop("fhistogram must be a matrix")
  if (length(dim(fhistogram)) != 2) stop("fhistogram must be 2D")
  if (threads < 0) stop("number of threads must not be negative")

  size_y <- dim(fhistogram)[1]
  size_x <- dim(fhistogram)[2]

  if (!is.matrix(mask) && !is.array(mask)) stop("kernel in matrix or array form expected")
  if (dim(mask)[1] != dim(mask)[2]) stop("kernel in square matrix expected")
  if (dim(mask)[1] %% 2 == 0) stop("kernel with odd size expected")

  kernel_pixels <- floor(dim(mask)[1] / 2)

  result <- .C("kernel_histogram",
    dimen = as.integer(c(size_x, size_y, kernel_pixels, threads)),
    kernel = as.single(mask),
    blurred_fhistogram = as.single(rep(0, size_x * size_y)),
    fhistogram = as.single(fhistogram)
  )

  blurred_fhistogram <- array(result$blurred_fhistogram, c(size_y, size_x))
  return(blurred_fhistogram)
}
