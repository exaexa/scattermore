#ifndef HEADER_H_
#define HEADER_H_

#include <stdio.h>

//main methods
void hist_int(const unsigned *pn, const unsigned *size_out, unsigned *matrix, const float *xlim, const float *ylim, const float *xy);
void kernel_hist_square(const unsigned *dim, const float *kernel, float *matrix, const float *data);
void kernel_hist_gauss(const unsigned *dim, float *matrix, const float *data, const float *sigma);
void hist_colorize(const unsigned *dim, float *matrix, const float *pallete, const float *data);
void raster(const unsigned *dim, const float *xlim, const float *ylim, float *matrix, const float *rgba, const float *xy);


//helper methods
float blur(const float *kernel, const float *data, const unsigned *dim, const size_t x, const size_t y);
void create_gauss(float *kernel, const size_t size, const float sigma);

#endif
