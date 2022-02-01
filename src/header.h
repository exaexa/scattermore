#include <stdio.h>

//main methods
void hist_int(const int *pn, const int *size_out, unsigned *matrix, const float *xlim, const float *ylim, const float *xy);
void kernel_hist_classic(const int *dim, const float *kernel, float *matrix, const float *data);


//helper methods
float blur(const float *kernel, const float *data, const int *dim, const size_t x, const size_t y);
