
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

  size_t i;
  for (i = 0; i < size_out_y; ++i) {
    size_t j;
    for (j = 0; j < size_out_x; ++j) {
      float sum = 0;

      int x;
      for (x = -radius; x <= radius; ++x) {
        int y;
        for (y = -radius; y <= radius; ++y) {
          int histogram_index = (j + x) * size_out_y + (i + y);
          float kernel_value =
            kernel[(radius + x) * kernel_size + (radius + y)];

          if (i + y >= 0 && i + y < size_out_y && j + x >= 0 &&
              j + x < size_out_x)
            sum += histogram[histogram_index] *
                   kernel_value; // else add nothing (zero border padding)
        }
      }
      blurred_histogram[j * size_out_y + i] = sum;
    }
  }
}
