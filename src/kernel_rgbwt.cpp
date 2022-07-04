
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
#include "thread_blocks.cpp"

#include <cmath>
#include <stddef.h>
#include <thread>
#include <vector>

using namespace std;

// blur data using its RGBWT matrix with given kernel
void
kernel_rgbwt(const unsigned *dim,
             const float *kernel,
             float *blurred_RGBWT,
             const float *RGBWT)
{
  const size_t size_out_x = dim[0];
  const size_t size_out_y = dim[1];
  const int radius = dim[2];
  const size_t size_kernel = radius * 2 + 1;
  const size_t size_out = size_out_x * size_out_y;
  size_t num_threads = dim[3];
  size_t block_size = 8;

  const size_t offset_R = size_out * 0;
  const size_t offset_G = size_out * 1;
  const size_t offset_B = size_out * 2;
  const size_t offset_W = size_out * 3;
  const size_t offset_T = size_out * 4;

  auto blurring_code = [&](size_t current_pixel_x, size_t current_pixel_y) {
    float R = 0, G = 0, B = 0, W = 0, T = 1;
    size_t offset = current_pixel_x * size_out_y + current_pixel_y;

    int x;
    for (x = -radius; x <= radius; ++x) { // blurring region around given point
      int y;
      for (y = -radius; y <= radius; ++y) {
        int x_shift = current_pixel_x + x;
        int y_shift = current_pixel_y + y;

        if (x_shift < 0 || x_shift >= (int)size_out_x || y_shift < 0 ||
            y_shift >= (int)size_out_y)
          continue;

        size_t offset_shift = x_shift * size_out_y + y_shift;
        float kernel_value = kernel[(radius + x) * size_kernel + (radius + y)];

        R += RGBWT[offset_shift + offset_R] * kernel_value;
        G += RGBWT[offset_shift + offset_G] * kernel_value;
        B += RGBWT[offset_shift + offset_B] * kernel_value;
        W += RGBWT[offset_shift + offset_W] * kernel_value;
        T *= 1 - ((1 - RGBWT[offset_shift + offset_T]) * kernel_value);
      }
    }

    blurred_RGBWT[offset + offset_R] = R;
    blurred_RGBWT[offset + offset_G] = G;
    blurred_RGBWT[offset + offset_B] = B;
    blurred_RGBWT[offset + offset_W] = W;
    blurred_RGBWT[offset + offset_T] = T;
  };

  threaded_foreach_2dblocks(
    size_out_x, size_out_y, block_size, block_size, num_threads, blurring_code);
}
