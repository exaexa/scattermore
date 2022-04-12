#include <R.h>
#include <R_ext/Rdynload.h>

#include "kernels.h"
#include "scatters.h"

static const R_CMethodDef cMethods[] = {
  { "scatter_histogram", (DL_FUNC)&scatter_histogram, 6 },
  { "kernel_histogram", (DL_FUNC)&kernel_histogram, 4 },
  { "histogram_to_rgbwt", (DL_FUNC)&histogram_to_rgbwt, 4 },
  { "scatter_singlecolor_rgbwt", (DL_FUNC)&scatter_singlecolor_rgbwt, 6 },
  { "scatter_multicolor_rgbwt", (DL_FUNC)&scatter_multicolor_rgbwt, 6 },
  { "scatter_indexed_rgbwt", (DL_FUNC)&scatter_indexed_rgbwt, 7 },
  { "kernel_rgbwt", (DL_FUNC)&kernel_rgbwt, 4 },
  { NULL, NULL, 0 }
};

void
R_init_Scattermore2(DllInfo *info)
{
  R_registerRoutines(info, cMethods, NULL, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
}
