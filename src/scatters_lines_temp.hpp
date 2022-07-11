
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

#ifndef SCATTERS_LINES_TEMP_H
#define SCATTERS_LINES_TEMP_H

#include<stddef.h>

template <typename PX>
inline void
plot_line_low(size_t x_start,
              size_t y_start,
              size_t x_finish,
              size_t y_finish,
              int skip_start_pixel,
              int skip_end_pixel,
              PX func)
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

    size_t x = x_start, y = y_start;
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
        if (!func(x, y))
            continue;

        if (D > 0) {
            y += yi;
            D += two_dxy;
        } else
            D += two_dy;
    }
}

template <typename PX>
inline void
plot_line_high(size_t x_start,
               size_t y_start,
               size_t x_finish,
               size_t y_finish,
               int skip_start_pixel,
               int skip_end_pixel,
               PX func)
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

    size_t x = x_start, y = y_start;
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
        if (!func(x, y))
            continue;

        if (D > 0) {
            x += xi;
            D += two_dxy;
        } else
            D += two_dx;
    }
}

#endif
