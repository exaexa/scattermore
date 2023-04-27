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

#include <R.h>
#include <R_ext/Rdynload.h>

#include "kernels.h"
#include "scatters.h"
#include "scatters_lines.h"

static const R_CMethodDef cMethods[] = {
  { "scatter_histogram", (DL_FUNC)&scatter_histogram, 6 },
  { "kernel_histogram", (DL_FUNC)&kernel_histogram, 4 },
  { "histogram_to_rgbwt", (DL_FUNC)&histogram_to_rgbwt, 4 },
  { "scatter_singlecolor_rgbwt", (DL_FUNC)&scatter_singlecolor_rgbwt, 6 },
  { "scatter_multicolor_rgbwt", (DL_FUNC)&scatter_multicolor_rgbwt, 6 },
  { "scatter_indexed_rgbwt", (DL_FUNC)&scatter_indexed_rgbwt, 7 },
  { "kernel_rgbwt", (DL_FUNC)&kernel_rgbwt, 4 },
  { "scatter_lines_rgbwt", (DL_FUNC)&scatter_lines_rgbwt, 7 },
  { "scatter_lines_histogram", (DL_FUNC)&scatter_lines_histogram, 6 },
  { NULL, NULL, 0 }
};

void // # nocov start
R_init_Scattermore(DllInfo *info)
{
  R_registerRoutines(info, cMethods, NULL, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
} // # nocov end
