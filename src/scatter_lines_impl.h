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

#ifndef SCATTERS_LINES_IMPL_H
#define SCATTERS_LINES_IMPL_H

#include <cstddef>
#include <cstdlib>

template<typename PF>
inline void
plot_line_low(int x_start,
              int y_start,
              int x_finish,
              int y_finish,
              int skip_start_pixel,
              int skip_end_pixel,
              PF pixel_function)
{
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

  int x = x_start, y = y_start;
  if (skip_start_pixel == 1) {
    if (D > 0) {
      y += yi;
      D += two_dxy;
    } else
      D += two_dy;
    ++x;
  }
  if (skip_end_pixel == 1)
    --x_finish;

  for (; x <= x_finish; ++x) {
    pixel_function(x, y);

    if (D > 0) {
      y += yi;
      D += two_dxy;
    } else
      D += two_dy;
  }
}

template<typename PF>
inline void
plot_line_high(int x_start,
               int y_start,
               int x_finish,
               int y_finish,
               int skip_start_pixel,
               int skip_end_pixel,
               PF pixel_function)
{
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

  int x = x_start, y = y_start;
  if (skip_start_pixel == 1) {
    if (D > 0) {
      x += xi;
      D += two_dxy;
    } else
      D += two_dx;
    ++y;
  }
  if (skip_end_pixel == 1)
    --y_finish;

  for (; y <= y_finish; ++y) {
    pixel_function(x, y);

    if (D > 0) {
      x += xi;
      D += two_dxy;
    } else
      D += two_dx;
  }
}

template<typename PF>
inline void
plot_line(int x0,
          int y0,
          int x1,
          int y1,
          int skip_start_pixel,
          int skip_end_pixel,
          PF pixel_function)
{
  /*
   * Bresenham algorithm; this is the initial case division, actual plotting is
   * handled by plot_line_low and plot_line_high.
   */
  if (abs(y1 - y0) < abs(x1 - x0)) {
    if (x0 > x1)
      plot_line_low(
        x1, y1, x0, y0, skip_end_pixel, skip_start_pixel, pixel_function);
    else
      plot_line_low(
        x0, y0, x1, y1, skip_start_pixel, skip_end_pixel, pixel_function);
  } else {
    if (y0 > y1)
      plot_line_high(
        x1, y1, x0, y0, skip_end_pixel, skip_start_pixel, pixel_function);
    else
      plot_line_high(
        x0, y0, x1, y1, skip_start_pixel, skip_end_pixel, pixel_function);
  }
}

#endif
