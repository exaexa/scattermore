
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

#include "scatters.h"
#include "thread_blocks.h"

#include <stddef.h>
#include <thread>
#include <vector>

using namespace std;

// calculate RGBWT matrix with given color for each point
void
scatter_multicolor_rgbwt(const unsigned *dim,
                         const float *xlim,
                         const float *ylim,
                         const float *RGBA,
                         float *RGBWT,
                         const float *xy)
{
  const size_t size_out_x = dim[0];
  const size_t size_out_y = dim[1];
  const size_t size_data = dim[2];
  const size_t size_out = size_out_x * size_out_y;
  const size_t RGBWT_size = 5;

  size_t nt = dim[3];
  if (nt == 0)
    nt = thread::hardware_concurrency();
  const size_t num_threads = nt;
  vector<vector<float>> RGBWT_copies(num_threads);

  const size_t offset_R = size_out * 0;
  const size_t offset_G = size_out * 1;
  const size_t offset_B = size_out * 2;
  const size_t offset_W = size_out * 3;
  const size_t offset_T = size_out * 4;
  const size_t offset_RGBA = 4;

  const float x_begin = xlim[0];
  const float x_end = xlim[1];
  const float x_bin = (size_out_x - 1) / (x_end - x_begin);

  const float y_begin = ylim[1];
  const float y_end = ylim[0];
  const float y_bin = (size_out_y - 1) / (y_end - y_begin);

  auto scatter_copies = [&](size_t thread_id, size_t current_pixel) {
    size_t x = (xy[current_pixel] - x_begin) *
               x_bin; // get new point coordinates for histogram
    size_t y = (xy[current_pixel + size_data] - y_begin) * y_bin;

    if (x >= size_out_x || y >= size_out_y)
      return;

    if (RGBWT_copies[thread_id].size() == 0) {
      RGBWT_copies[thread_id].resize(size_out * RGBWT_size, 0);
      for (size_t j = 0; j < size_out; ++j)
        RGBWT_copies[thread_id][j + offset_T] = 1;
    }

    float R = RGBA[offset_RGBA * current_pixel + 0];
    float G = RGBA[offset_RGBA * current_pixel + 1];
    float B = RGBA[offset_RGBA * current_pixel + 2];
    float A = RGBA[offset_RGBA * current_pixel + 3];

    size_t offset = x * size_out_y + y;
    RGBWT_copies[thread_id][offset + offset_R] += R * A;
    RGBWT_copies[thread_id][offset + offset_G] += G * A;
    RGBWT_copies[thread_id][offset + offset_B] += B * A;
    RGBWT_copies[thread_id][offset + offset_W] += A;
    RGBWT_copies[thread_id][offset + offset_T] *= 1 - A;
  };

  auto sum_copies = [&](size_t /*thread_id*/, size_t current_pixel) {
    float R_sum = 0, G_sum = 0, B_sum = 0, W_sum = 0, T_mul = 1;

    for (size_t thread_id = 0; thread_id < num_threads; ++thread_id) {
      R_sum += RGBWT_copies[thread_id][current_pixel + offset_R];
      G_sum += RGBWT_copies[thread_id][current_pixel + offset_G];
      B_sum += RGBWT_copies[thread_id][current_pixel + offset_B];
      W_sum += RGBWT_copies[thread_id][current_pixel + offset_W];
      T_mul *= RGBWT_copies[thread_id][current_pixel + offset_T];
    }

    RGBWT[current_pixel + offset_R] = R_sum;
    RGBWT[current_pixel + offset_G] = G_sum;
    RGBWT[current_pixel + offset_B] = B_sum;
    RGBWT[current_pixel + offset_W] = W_sum;
    RGBWT[current_pixel + offset_T] = T_mul;
  };

  threaded_foreach_1dblocks(size_data, 0, num_threads, scatter_copies);
  threaded_foreach_1dblocks(size_out, 0, num_threads, sum_copies);
}
