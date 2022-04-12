#ifndef KERNELS_H_
#define KERNELS_H_
#include <stdio.h>

void
kernel_histogram(const unsigned *dim,
                 const float *kernel,
                 float *blurred_histogram,
                 const float *histogram);
void
kernel_rgbwt(const unsigned *dim,
             const float *kernel,
             float *blurred_RGBWT,
             const float *RGBWT);

#endif
