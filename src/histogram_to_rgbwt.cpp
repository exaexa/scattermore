
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

// colorize histogram with given color palette
void
histogram_to_rgbwt(const unsigned *dim,
                   float *RGBWT,
                   const float *palette,
                   const float *histogram)
{
  const size_t size_out_y = dim[0];
  const size_t size_out_x = dim[1];
  const size_t size_palette = dim[2];
  const size_t num_threads = dim[3];
  const float bin = 1.0 / size_palette;
  const size_t size_out = size_out_y * size_out_x;
  const size_t block_size = 8;

  const size_t offset_R = size_out * 0;
  const size_t offset_G = size_out * 1;
  const size_t offset_B = size_out * 2;
  const size_t offset_W = size_out * 3;
  const size_t offset_T = size_out * 4;

  auto change_format = [&](size_t /*thread_id*/, size_t current_pixel) {
    float histogram_value = histogram[current_pixel];
    size_t palette_index =
      ((size_t)(histogram_value / bin)); // determining column in palette

    if (palette_index == size_palette)
      --palette_index;

    float R = palette[4 * palette_index + 0];
    float G = palette[4 * palette_index + 1];
    float B = palette[4 * palette_index + 2];
    float A = palette[4 * palette_index + 3];

    RGBWT[current_pixel + offset_R] = R;
    RGBWT[current_pixel + offset_G] = G;
    RGBWT[current_pixel + offset_B] = B;
    RGBWT[current_pixel + offset_W] = 1;
    RGBWT[current_pixel + offset_T] = 1 - A;
  };

  threaded_foreach_1dblocks(size_out, block_size, num_threads, change_format);
}
