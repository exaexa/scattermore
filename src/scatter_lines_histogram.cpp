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

#include "scatter_lines_impl.h"
#include "scatters_lines.h"

// create histogram from given lines
void
scatter_lines_histogram(const float *xy,
                        const unsigned *dim,
                        const float *xlim,
                        const float *ylim,
                        const int *skip,
                        unsigned *histogram)
{
  const size_t size_out_x = dim[0];
  const size_t size_out_y = dim[1];
  const size_t size_data = dim[2];

  const int skip_start_pixel = skip[0];
  const int skip_end_pixel = skip[1];

  const float x_begin = xlim[0];
  const float x_end = xlim[1];
  const float x_bin = (size_out_x - 1) / (x_end - x_begin);

  const float y_begin = ylim[1];
  const float y_end = ylim[0];
  const float y_bin = (size_out_y - 1) / (y_end - y_begin);

  // lambda expression used for individual pixel when plotting a line
  auto pixel_function_histogram =
    [histogram, size_out_x, size_out_y](size_t x, size_t y) {
      if (x < size_out_x && y < size_out_y)
        ++histogram[x * size_out_y + y];
    };

  for (size_t i = 0; i < size_data; ++i) {
    int x0 = (xy[0 * size_data + i] - x_begin) * x_bin;
    int y0 = (xy[1 * size_data + i] - y_begin) * y_bin;
    int x1 = (xy[2 * size_data + i] - x_begin) * x_bin;
    int y1 = (xy[3 * size_data + i] - y_begin) * y_bin;

    plot_line(x0,
              y0,
              x1,
              y1,
              skip_start_pixel,
              skip_end_pixel,
              pixel_function_histogram);
  }
}
