/*
 * This file is part of scattermore.
 *
 * Copyright (C) 2022-2023 Mirek Kratochvil <exa.exa@gmail.com>
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

#include "macros.h"
#include "scatters.h"

#include <cstddef>

void
scatter_histogram(const unsigned *pn,
                  const unsigned *size_out,
                  unsigned *histogram,
                  const float *xlim,
                  const float *ylim,
                  const float *xy)
{
  const size_t size_data = *pn;
  const size_t size_out_x = size_out[0];
  const size_t size_out_y = size_out[1];

  const float x_begin = xlim[0];
  const float x_end = xlim[1];
  const float x_bin = (size_out_x - 1) / (x_end - x_begin);

  const float y_begin = ylim[1];
  const float y_end = ylim[0];
  const float y_bin = (size_out_y - 1) / (y_end - y_begin);

  for (size_t i = 0; i < size_data; ++i) {
    size_t x = f2i((xy[i] - x_begin) * x_bin);
    size_t y = f2i((xy[i + size_data] - y_begin) * y_bin);

    if (x >= size_out_x || y >= size_out_y)
      continue;

    ++histogram[x * size_out_y + y];
  }
}
