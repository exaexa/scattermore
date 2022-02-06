#include <R.h>
#include <R_ext/Rdynload.h>

#include "header.h"

static const R_CMethodDef cMethods[] = {
	{ "hist_int", (DL_FUNC)&hist_int, 6 },
	{ "kernel_hist_square", (DL_FUNC)&kernel_hist_square, 4 },
	{ "kernel_hist_gauss", (DL_FUNC)&kernel_hist_gauss, 4 },
	{ "hist_colorize", (DL_FUNC)&hist_colorize, 4 },
	{ "data_one", (DL_FUNC)&data_one, 6 },
	{ "data_more", (DL_FUNC)&data_more, 6 },
	{ "kernel_data_circle", (DL_FUNC)&kernel_data_circle, 4 },
	{ "kernel_data_gauss", (DL_FUNC)&kernel_data_gauss, 4 },
	{ NULL, NULL, 0 }
};

void
R_init_Scattermore2(DllInfo *info)
{
	R_registerRoutines(info, cMethods, NULL, NULL, NULL);
	R_useDynamicSymbols(info, FALSE);
}
