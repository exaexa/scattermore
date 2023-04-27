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

#ifndef SCATTERS_H
#define SCATTERS_H

#ifdef __cplusplus
extern "C"
{
#endif

  void scatter_histogram(const unsigned *pn,
                         const unsigned *size_out,
                         unsigned *histogram,
                         const float *xlim,
                         const float *ylim,
                         const float *xy);

  void scatter_singlecolor_rgbwt(const unsigned *dim,
                                 const float *xlim,
                                 const float *ylim,
                                 const float *RGBA,
                                 float *RGBWT,
                                 const float *xy);

  void scatter_multicolor_rgbwt(const unsigned *dim,
                                const float *xlim,
                                const float *ylim,
                                const float *RGBA,
                                float *RGBWT,
                                const float *xy);

  void scatter_indexed_rgbwt(const unsigned *dim,
                             const float *xlim,
                             const float *ylim,
                             const float *palette,
                             float *RGBWT,
                             const unsigned *map,
                             const float *xy);

  void histogram_to_rgbwt(const unsigned *dim,
                          float *RGBWT,
                          const float *pallete,
                          const float *histogram);

#ifdef __cplusplus
}
#endif

#endif
