
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
#include "thread_blocks.h"

#include <stddef.h>

using namespace std;

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
  size_t num_threads = dim[3];
  size_t block_size = 8;

  auto apply_kernel = [&](size_t /*thread_id*/,
                          size_t current_pixel_x,
                          size_t current_pixel_y) {
    float sum = 0;

    int x;
    for (x = -radius; x <= radius; ++x) {
      int y;
      for (y = -radius; y <= radius; ++y) {
        int x_shift = current_pixel_x + x;
        int y_shift = current_pixel_y + y;
        int histogram_index = (x_shift)*size_out_y + (y_shift);
        float kernel_value = kernel[(radius + x) * kernel_size + (radius + y)];

        if (y_shift >= 0 && y_shift < size_out_y && x_shift >= 0 &&
            x_shift < size_out_x)
          sum += histogram[histogram_index] *
                 kernel_value; // else add nothing (zero border padding)
      }
    }
    blurred_histogram[current_pixel_x * size_out_y + current_pixel_y] = sum;
  };

  threaded_foreach_2dblocks(
    size_out_x, size_out_y, block_size, block_size, num_threads, apply_kernel);
}
