
/*
 * This file is part of scattermore.
 *
 * Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
 *               2022 Tereza Kulichova <kulichova.t@gmail.com>
 *
 * scattermore is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * scattermore is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * scattermore. If not, see <https://www.gnu.org/licenses/>.
 */

#include "kernels.h"
#include "macros.h"

#include <stddef.h>

// blur histogram using given kernel
void
kernel_histogram(const unsigned *dim,
                 const float *kernel,
                 float *blurred_histogram,
                 const float *histogram)
{
  const size_t size_out_x = dim[0];
  const size_t size_out_y = dim[1];
  const int radius = dim[2];
  const size_t kernel_size = 2 * radius + 1;

  int x;
  for (x = -radius; x <= radius; ++x) {
    int j_begin =
      max(1 - x, 1); // there is no need to check edge cases using if
    int j_end = min(size_out_x - x, size_out_x);

    int y;
    for (y = -radius; y <= radius; ++y) {
      int i_begin = max(1 - y, 1); // the same as above
      int i_end = min(size_out_y - y, size_out_y);

      size_t i;
      for (i = i_begin; i < i_end; ++i) {
        size_t j;
        for (j = j_begin; j < j_end; ++j) {
          int x_shift = j + x;
          int y_shift = i + y;
          int histogram_index = x_shift * size_out_y + y_shift;
          float kernel_value =
            kernel[(radius + x) * kernel_size + (radius + y)];

          blurred_histogram[j * size_out_y + i] +=
            histogram[histogram_index] *
            kernel_value; // else add nothing (zero border padding)
        }
      }
    }
  }
}
