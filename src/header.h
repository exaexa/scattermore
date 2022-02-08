#ifndef HEADER_H_
#define HEADER_H_

#include <stdio.h>

//main methods
void hist_int(const unsigned *pn, const unsigned *size_out, unsigned *matrix, const float *xlim, const float *ylim, const float *xy);
void kernel_hist_square(const unsigned *dim, const float *kernel, float *matrix, const float *data);
void kernel_hist_gauss(const unsigned *dim, float *matrix, const float *data, const float *sigma);
void hist_colorize(const unsigned *dim, unsigned *matrix, const unsigned *pallete, const float *data);
void data_one(const unsigned *dim, const float *xlim, const float *ylim, const float *rgba, float *rgbwt, const float *xy);
void data_more(const unsigned *dim, const float *xlim, const float *ylim, const float *rgba, float *rgbwt, const float *xy);
void kernel_data_circle(const unsigned *dim, const float *radius, float *matrix, const float *rgbwt);
void kernel_data_gauss(const unsigned *dim, float *matrix, const float *rgba, const float *approx_limit, const float *sigma);


//helper methods
float blur(const float *kernel, const float *data, const unsigned *dim, const size_t x, const size_t y);
void create_gauss(float *kernel, const size_t size, const float sigma);

#endif
