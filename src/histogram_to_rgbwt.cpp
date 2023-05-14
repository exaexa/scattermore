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

#include "scatters.h"

#include <stddef.h>

// colorize histogram with given color palette
void
histogram_to_rgbwt(const unsigned *dim,
                   float *RGBWT,
                   const float *palette,
                   const int *histogram)
{
  const size_t size_out_y = dim[0];
  const size_t size_out_x = dim[1];
  const size_t size_palette = dim[2];
  const size_t size_out = size_out_y * size_out_x;

  for (size_t i = 0; i < size_out; ++i) {
    int histogram_value = histogram[i];
    if(histogram_value < 0) histogram_value = 0;
    if(histogram_value >= size_palette) histogram_value = size_palette - 1;

    const float R = palette[4 * histogram_value + 0];
    const float G = palette[4 * histogram_value + 1];
    const float B = palette[4 * histogram_value + 2];
    const float A = palette[4 * histogram_value + 3];

    RGBWT[i + size_out * 0] = R * A;
    RGBWT[i + size_out * 1] = G * A;
    RGBWT[i + size_out * 2] = B * A;
    RGBWT[i + size_out * 3] = A;
    RGBWT[i + size_out * 4] = 1 - A;
  }
}
