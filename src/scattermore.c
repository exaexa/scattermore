
/* This file is part of scattermore.
 *
 * Copyright (C) 2019-2020 Mirek Kratochvil <exa.exa@gmail.com>
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
 *
 * -----
 *
 * format this file with:
 * clang-format-7 -style="{BasedOnStyle: Mozilla, UseTab: ForIndentation, IndentWidth: 8, TabWidth: 8}"
 */

#include <R.h>
#include <R_ext/Rdynload.h>

#include <stdio.h>

void
scattermore(const int *pn,
            const int *pncol,
            const int *size,
            const float *xlim,
            const float *ylim,
            const float *pcex,
            const float *xy,
            const unsigned *rgba,
            unsigned *rd)
{
	const size_t n = *pn, ncol = *pncol, sizex = size[0], sizey = size[1],
	             sizexy = sizex * sizey, offg = sizexy, offb = offg * 2,
	             offa = offg * 3;
	const float xb = xlim[0], xe = xlim[1], xips = (sizex - 1) / (xe - xb),
	            yb = ylim[1], ye = ylim[0], yips = (sizey - 1) / (ye - yb),
	            cex = *pcex;

	size_t i;
	for (i = 0; i < sizexy * 4; ++i)
		rd[i] = 0;

	if (cex < 0.000000001) { // epsilol
		if (ncol == 1) {
#define get_color(ii)                                                          \
	unsigned sa = rgba[ii * 4 + 3] * 128,                                  \
	         sr = rgba[ii * 4 + 0] * sa / 255,                             \
	         sg = rgba[ii * 4 + 1] * sa / 255,                             \
	         sb = rgba[ii * 4 + 2] * sa / 255;
			get_color(0);

			for (i = 0; i < n; ++i) {
#define get_xy                                                                 \
	const unsigned x = (xy[i] - xb) * xips, y = (xy[i + n] - yb) * yips;   \
	if (x >= sizex || y >= sizey)                                          \
		continue;
				get_xy;
#define paint_point                                                            \
	const size_t off = y + sizey * x;                                      \
	const unsigned dr = rd[off], dg = rd[off + offg], db = rd[off + offb], \
	               da = rd[off + offa];                                    \
                                                                               \
	rd[off] = sr + dr - ((sa * dr) / 32640);                               \
	rd[off + offg] = sg + dg - ((sa * dg) / 32640);                        \
	rd[off + offb] = sb + db - ((sa * db) / 32640);                        \
	rd[off + offa] = sa + da - ((sa * da) / 32640);
#define paint_point_vars(sr, sg, sb, sa)                                       \
	const size_t off = y + sizey * x;                                      \
	const unsigned dr = rd[off], dg = rd[off + offg], db = rd[off + offb], \
	               da = rd[off + offa];                                    \
                                                                               \
	rd[off] = sr + dr - ((sa * dr) / 32640);                               \
	rd[off + offg] = sg + dg - ((sa * dg) / 32640);                        \
	rd[off + offb] = sb + db - ((sa * db) / 32640);                        \
	rd[off + offa] = sa + da - ((sa * da) / 32640);

				paint_point;
			}
		} else {
			for (i = 0; i < n; ++i) {
				get_color(i);
				get_xy;

				paint_point;
			}
		}
	} else {
		const int cr = ceilf(cex) + 1, crsq = cex * cex,
		          crsq1 = (cex + 1) * (cex + 1), crsqd = crsq1 - crsq;
		if (ncol == 1) {
			get_color(0);
			for (i = 0; i < n; ++i) {
#define paint_circle                                                           \
	const int cx = (xy[i] - xb) * xips, cy = (xy[i + n] - yb) * yips,      \
	          pxb = cx <= cr ? 0 : cx - cr,                                \
	          pxe = cx + cr + 1 >= (int)sizex ? (int)sizex : cx + cr + 1,  \
	          pyb = cy <= cr ? 0 : cy - cr,                                \
	          pye = cy + cr + 1 >= (int)sizey ? (int)sizey : cy + cr + 1;  \
                                                                               \
	int x, y;                                                              \
	for (x = pxb; x < pxe; ++x)                                            \
		for (y = pyb; y < pye; ++y) {                                  \
			int tmp = (x - cx) * (x - cx) + (y - cy) * (y - cy);   \
			if (tmp > crsq1)                                       \
				continue;                                      \
			if (tmp < crsq) {                                      \
				paint_point;                                   \
				continue;                                      \
			}                                                      \
			tmp = crsq1 - tmp;                                     \
			const unsigned nsa = sa * tmp / crsqd;                 \
			paint_point_vars((sr * tmp / crsqd),                   \
			                 (sg * tmp / crsqd),                   \
			                 (sb * tmp / crsqd),                   \
			                 nsa);                                 \
		}

				paint_circle;
			}
		} else {
			for (i = 0; i < n; ++i) {
				get_color(i);
				paint_circle;
			}
		}
	}

	// un-premultiply alpha
	for (i = 0; i < sizexy; ++i) {
		if (!rd[i + offa])
			continue;
		rd[i] = (rd[i] * 255) / rd[i + offa];
		rd[i + offg] = (rd[i + offg] * 255) / rd[i + offa];
		rd[i + offb] = (rd[i + offb] * 255) / rd[i + offa];
		rd[i + offa] /= 128;
	}
}

static const R_CMethodDef cMethods[] = {
	{ "scattermore", (DL_FUNC)&scattermore, 9 },
	{ NULL, NULL, 0 }
};

void
R_init_Scattermore(DllInfo *info)
{
	R_registerRoutines(info, cMethods, NULL, NULL, NULL);
	R_useDynamicSymbols(info, FALSE);
}
