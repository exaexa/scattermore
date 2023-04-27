/*
 * This file is part of scattermore.
 *
 * Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
 *               2022-2023 Tereza Kulichova <kulichova.t@gmail.com>
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

#include "scatters_lines.h"
#include "scatters_lines_impl.h"

#include <cstdlib>

// draw given lines
void
scatter_lines_rgbwt(const float *xy,
                    const unsigned *dim,
                    const float *xlim,
                    const float *ylim,
                    const float *RGBA,
                    const int *skip,
                    float *RGBWT)
{
  const size_t size_out_x = dim[0];
  const size_t size_out_y = dim[1];
  const size_t size_data = dim[2];
  const size_t size_out = size_out_y * size_out_x;

  const size_t offset_R = size_out * 0;
  const size_t offset_G = size_out * 1;
  const size_t offset_B = size_out * 2;
  const size_t offset_W = size_out * 3;
  const size_t offset_T = size_out * 4;

  const int skip_start_pixel = skip[0];
  const int skip_end_pixel = skip[1];

  const float x_begin = xlim[0];
  const float x_end = xlim[1];
  const float x_bin = (size_out_x - 1) / (x_end - x_begin);

  const float y_begin = ylim[1];
  const float y_end = ylim[0];
  const float y_bin = (size_out_y - 1) / (y_end - y_begin);

  float R = RGBA[0];
  float G = RGBA[1];
  float B = RGBA[2];
  float A = RGBA[3];

  // lambda expression used for individual pixel when plotting a line
  auto pixel_function_rgbwt = [R,
                               G,
                               B,
                               A,
                               size_out_x,
                               size_out_y,
                               offset_R,
                               offset_G,
                               offset_B,
                               offset_W,
                               offset_T,
                               RGBWT](size_t x, size_t y) {
    if (x < size_out_x && y < size_out_y) {
      size_t offset = x * size_out_y + y;
      RGBWT[offset + offset_R] += R * A;
      RGBWT[offset + offset_G] += G * A;
      RGBWT[offset + offset_B] += B * A;
      RGBWT[offset + offset_W] += A;
      RGBWT[offset + offset_T] *= 1 - A;
    }
  };

  for (size_t i = 0; i < size_data; ++i) {
    int x0 = (xy[0 * size_data + i] - x_begin) * x_bin;
    int y0 = (xy[1 * size_data + i] - y_begin) * y_bin;
    int x1 = (xy[2 * size_data + i] - x_begin) * x_bin;
    int y1 = (xy[3 * size_data + i] - y_begin) * y_bin;

    plot_line(
      x0, y0, x1, y1, skip_start_pixel, skip_end_pixel, pixel_function_rgbwt);
  }
}
