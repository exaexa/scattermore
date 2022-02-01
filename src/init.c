#include <R.h>
#include <R_ext/Rdynload.h>

#include "header.h"

static const R_CMethodDef cMethods[] = {
	{ "hist_int", (DL_FUNC)&hist_int, 6 },
	{ "kernel_hist_classic", (DL_FUNC)&kernel_hist_classic, 4 },
	{ NULL, NULL, 0 }
};

void
R_init_Scattermore2(DllInfo *info)
{
	R_registerRoutines(info, cMethods, NULL, NULL, NULL);
	R_useDynamicSymbols(info, FALSE);
}
