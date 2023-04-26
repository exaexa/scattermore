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

#' apply_kernel_histogram
#'
#' Blur given histogram using `square` or `gauss` filtering.
#'
#' @param fhistogram Matrix or array interpreted as histogram.
#'
#' @param filter Either `circle`, `square`, `gauss` or `own`, defaults to `circle`.
#'
#' @param mask Own kernel used for blurring, `filter` parameter has to be set to `own`.
#'
#' @param radius Used for determining size of kernel, defaults to `2`.
#'
#' @param sigma Parameter for gaussian filtering, defaults to `radius / 2`.
#'
#' @param threads Number of parallel threads (default 0 chooses hardware concurrency).
#'
#' @return Blurred histogram with the result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE

apply_kernel_histogram <- function(fhistogram,
                                   filter = "circle",
                                   mask,
                                   radius = 2,
                                   sigma = radius / 2,
                                   threads = 0) {
  if (!is.matrix(fhistogram) && !is.array(fhistogram)) stop("fhistogram must be a matrix")
  if (length(dim(fhistogram)) != 2) stop("fhistogram must be 2D")
  if (!is.numeric(radius) || !is.numeric(sigma) || length(radius) != 1 || length(sigma) != 1) {
    stop("parameters radius and sigma must be numbers")
  }
  if (radius <= 0) stop("radius must be positive")
  if (threads < 0) stop("number of threads must not be negative")

  size_y <- dim(fhistogram)[1]
  size_x <- dim(fhistogram)[2]

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


  result <- .C("kernel_histogram",
    dimen = as.integer(c(size_x, size_y, kernel_pixels, threads)),
    kernel = as.single(kernel),
    blurred_fhistogram = as.single(rep(0, size_x * size_y)),
    fhistogram = as.single(fhistogram)
  )

  blurred_fhistogram <- array(result$blurred_fhistogram, c(size_y, size_x))
  return(blurred_fhistogram)
}
