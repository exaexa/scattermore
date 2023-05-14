
# This file is part of scattermore.
#
# Copyright (C) 2022-2023 Mirek Kratochvil <exa.exa@gmail.com>
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

#' default_kernel
#'
#' Create a nice defaulted kernel for `apply_kernel_*` functions.
#' Parameters are documented in the exported functions.
default_kernel <- function(filter, radius, sigma) {
  if (!is.numeric(radius) || !is.numeric(sigma) || length(radius) != 1 || length(sigma) != 1) {
    stop("parameters radius and sigma must be numbers")
  }
  if (radius <= 0) stop("radius must be positive")

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
  } else {
    stop("unsupported kernel shape")
  }
}
