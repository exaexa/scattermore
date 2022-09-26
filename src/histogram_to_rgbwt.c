
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

// COMPILE WITH -MSSE4
#include "scatters.h"

#include <xmmintrin.h>
#include <intrin.h>
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
  const float bin = 1.0 / size_palette;
  const size_t size_out = size_out_y * size_out_x;

  const size_t offset_R = size_out * 0;
  const size_t offset_G = size_out * 1;
  const size_t offset_B = size_out * 2;
  const size_t offset_W = size_out * 3;
  const size_t offset_T = size_out * 4;

  const float *histogram_end = histogram + size_out;
  const float *histogram_end_rest = histogram_end - 3;  //multiplier of 4
  const __m128 bins = _mm_set1_ps(bin);
  const __m128 ones = _mm_set1_ps(1);
  const __m128i fours = _mm_set1_epi32(4);
  const __m128i sizes_palette = _mm_set1_epi32(size_palette - 1);

  for(; histogram < histogram_end_rest; histogram += 4, RGBWT += 4) {
    const __m128 histogram_values = _mm_loadu_ps(histogram);
    // palette indices multiplied by 4
    __m128i palette_indices = _mm_mul_epi32(_mm_castps_si128(_mm_div_ps(histogram_values, bins)), fours);
    // correct if one of the indices is equal to size_palette
    palette_indices = _mm_min_epi32(palette_indices, sizes_palette);

    // load RGBA values
    __m128 data_0 = _mm_load_ps(palette + _mm_extract_epi32(palette_indices, 0) * 4);
    __m128 data_1 = _mm_load_ps(palette + _mm_extract_epi32(palette_indices, 1) * 4);
    __m128 data_2 = _mm_load_ps(palette + _mm_extract_epi32(palette_indices, 2) * 4);
    __m128 data_3 = _mm_load_ps(palette + _mm_extract_epi32(palette_indices, 3) * 4);
    // transpose and get SoA format
    _MM_TRANSPOSE4_PS(data_0, data_1, data_2, data_3);

    _mm_store_ps(RGBWT + offset_R, data_0);
    _mm_store_ps(RGBWT + offset_G, data_1);
    _mm_store_ps(RGBWT + offset_B, data_2);
    _mm_store_ps(RGBWT + offset_W, ones);
    _mm_store_ps(RGBWT + offset_T, _mm_sub_ps(ones, data_3)); //RGBWT[offset + offset_T] = 1 - A;
  }

  for(; histogram < histogram_end; ++histogram, ++RGBWT){  //do the rest values
    float histogram_value = *histogram;
    size_t palette_index =
      ((size_t)(histogram_value / bin)); // determining column in palette

    if (palette_index == size_palette)
      --palette_index;

    float R = palette[4 * palette_index + 0];
    float G = palette[4 * palette_index + 1];
    float B = palette[4 * palette_index + 2];
    float A = palette[4 * palette_index + 3];

    // don't add offset
    RGBWT[offset_R] = R;
    RGBWT[offset_G] = G;
    RGBWT[offset_B] = B;
    RGBWT[offset_W] = 1;
    RGBWT[offset_T] = 1 - A;
  }
}
