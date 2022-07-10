
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

#include "lines.h"

#include <stddef.h>
#include <cstdlib>

// use Bresenham algorithm to draw a line
void
scatter_lines_rgbwt(const float *xy,
                    const unsigned *dim,
                    const float *xlim,
                    const float *ylim,
                    const float *RGBA,
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

  auto plot_line_low =
    [&](size_t x_start, size_t y_start, size_t x_finish, size_t y_finish) {
      int dx = x_finish - x_start;
      int dy = y_finish - y_start;
      int yi = 1;

      if (dy < 0) {
        yi = -1;
        dy = -dy;
      }

      int two_dy = 2 * dy;
      int two_dxy = 2 * (dy - dx);
      int D = two_dy - dx;

      for (size_t x = x_start, y = y_start; x <= x_finish; ++x) {
        if (x >= size_out_x || y >= size_out_y)
          continue;

        size_t offset = x * size_out_y + y;
        RGBWT[offset + offset_R] += R * A;
        RGBWT[offset + offset_G] += G * A;
        RGBWT[offset + offset_B] += B * A;
        RGBWT[offset + offset_W] += A;
        RGBWT[offset + offset_T] *= 1 - A;

        if (D > 0) {
          y += yi;
          D += two_dxy;
          continue;
        }
        D += two_dy;
      }
    };

  auto plot_line_high =
    [&](size_t x_start, size_t y_start, size_t x_finish, size_t y_finish) {
      int dx = x_finish - x_start;
      int dy = y_finish - y_start;
      int xi = 1;

      if (dx < 0) {
        xi = -1;
        dx = -dx;
      }

      int two_dx = 2 * dx;
      int two_dxy = 2 * (dx - dy);
      int D = two_dx - dy;

      for (size_t x = x_start, y = y_start; y <= y_finish; ++y) {
        if (x >= size_out_x || y >= size_out_y)
          continue;

        size_t offset = x * size_out_y + y;
        RGBWT[offset + offset_R] += R * A;
        RGBWT[offset + offset_G] += G * A;
        RGBWT[offset + offset_B] += B * A;
        RGBWT[offset + offset_W] += A;
        RGBWT[offset + offset_T] *= 1 - A;

        if (D > 0) {
          x += xi;
          D += two_dxy;
          continue;
        }
        D += two_dx;
      }
    };

  for (size_t i = 0; i < size_data; ++i) {
    // initialization for Bresenham algorithm
    int x0 = (xy[0 * size_data + i] - x_begin) * x_bin;
    int y0 = (xy[1 * size_data + i] - y_begin) * y_bin;
    int x1 = (xy[2 * size_data + i] - x_begin) * x_bin;
    int y1 = (xy[3 * size_data + i] - y_begin) * y_bin;

    // initial case division
    if (abs(y1 - y0) < abs(x1 - x0)) {
      if (x0 > x1)
        plot_line_low(x1, y1, x0, y0);
      else
        plot_line_low(x0, y0, x1, y1);
    } else {
      if (y0 > y1)
        plot_line_high(x1, y1, x0, y0);
      else
        plot_line_high(x0, y0, x1, y1);
    }
  }
}
