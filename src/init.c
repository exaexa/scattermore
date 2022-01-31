#include <R.h>
#include <R_ext/Rdynload.h>

#include <stdio.h>

void hist_int(const int *pn, const int *size, const int *matrix, const float *xy);

static const R_CMethodDef cMethods[] = {
	{ "hist_int", (DL_FUNC)&hist_int, 6 },
	{ NULL, NULL, 0 }
};

void
R_init_Scattermore2(DllInfo *info)
{
	R_registerRoutines(info, cMethods, NULL, NULL, NULL);
	R_useDynamicSymbols(info, FALSE);
}
