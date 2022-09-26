
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

#include <smmintrin.h>
#include <stddef.h>

// colorize histogram with given color palette
void
histogram_to_rgbwt(const unsigned *dim,
                   float *RGBWT,
                   const float *palette,
                   const float *histogram,
                   const float *extremes)
{
  const size_t size_out_y = dim[0], size_out_x = dim[1], size_palette = dim[2],
               size_out = size_out_y * size_out_x;
  const float bin = 1.0 / size_palette;
  const float minimum = extremes[0], maximum = extremes[1];

  float difference = maximum - minimum;
  if (difference == 0)
    difference = 1; // not divide by 0

  const size_t offset_R = size_out * 0, offset_G = size_out * 1,
               offset_B = size_out * 2, offset_W = size_out * 3,
               offset_T = size_out * 4;

  const float *histogram_end = histogram + size_out;
  const float *histogram_end_rest = histogram_end - 3; // multiplier of 4
  const __m128 ones = _mm_set1_ps(1), bins = _mm_div_ps(ones, _mm_set1_ps(bin)),
               minimums = _mm_set1_ps(minimum),
               differences = _mm_div_ps(ones, _mm_set1_ps(difference));
  const __m128i sizes_palette = _mm_set1_epi32(size_palette - 1);

  for (; histogram < histogram_end_rest; histogram += 4, RGBWT += 4) {
    __m128 histogram_values = _mm_loadu_ps(histogram);
    // normalize histogram_values
    histogram_values =
      _mm_mul_ps(_mm_sub_ps(histogram_values, minimums), differences);
    // palette indices multiplied by 4
    __m128i palette_indices =
      _mm_cvtps_epi32(_mm_mul_ps(histogram_values, bins));
    // correct if one of the indices is equal to size_palette
    palette_indices = _mm_min_epi32(palette_indices, sizes_palette);

    // load RGBA values
    const __m128
      data0 = _mm_loadu_ps(palette + 4 * _mm_extract_epi32(palette_indices, 0)),
      data1 = _mm_loadu_ps(palette + 4 * _mm_extract_epi32(palette_indices, 1)),
      data2 = _mm_loadu_ps(palette + 4 * _mm_extract_epi32(palette_indices, 2)),
      data3 = _mm_loadu_ps(palette + 4 * _mm_extract_epi32(palette_indices, 3));
    // transpose and store SoA format directly (based on MM_TRANSPOSE4_PS)
    const __m128 t0 = _mm_unpacklo_ps(data0, data1),
                 t1 = _mm_unpackhi_ps(data0, data1),
                 t2 = _mm_unpacklo_ps(data2, data3),
                 t3 = _mm_unpackhi_ps(data2, data3);

    _mm_storeu_ps(RGBWT + offset_R, _mm_movelh_ps(t0, t2));
    _mm_storeu_ps(RGBWT + offset_G, _mm_movehl_ps(t2, t0));
    _mm_storeu_ps(RGBWT + offset_B, _mm_movelh_ps(t1, t3));

    const __m128 alpha = _mm_movehl_ps(t3, t1);
    _mm_storeu_ps(RGBWT + offset_W, alpha);
    _mm_storeu_ps(RGBWT + offset_T,
                  _mm_sub_ps(ones, alpha)); // RGBWT[offset + offset_T] = 1 - A;
  }

  for (; histogram < histogram_end; ++histogram, ++RGBWT) { // do the rest
                                                            // values
    float histogram_value = *histogram;
    size_t palette_index =
      ((size_t)(histogram_value / bin)); // determining column in palette

    if (palette_index == size_palette)
      --palette_index;

    float R = palette[4 * palette_index + 0],
          G = palette[4 * palette_index + 1],
          B = palette[4 * palette_index + 2],
          A = palette[4 * palette_index + 3];

    // don't add offset
    RGBWT[offset_R] = R;
    RGBWT[offset_G] = G;
    RGBWT[offset_B] = B;
    RGBWT[offset_W] = A;
    RGBWT[offset_T] = 1 - A;
  }
}
