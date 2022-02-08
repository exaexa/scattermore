#ifndef HEADER_H_
#define HEADER_H_

#include <stdio.h>

//main methods
void hist_int(const unsigned *pn, const unsigned *size_out, unsigned *histogram, const float *xlim, const float *ylim, const float *xy);
void kernel_hist_square(const unsigned *dim, const float *kernel, float *blurred_histogram, const float *histogram);
void kernel_hist_gauss(const unsigned *dim, float *blurred_histogram, const float *histogram, const float *sigma);
void hist_colorize(const unsigned *dim, float *RGBWT, const float *pallete, const float *histogram);
void data_one(const unsigned *dim, const float *xlim, const float *ylim, const float *RGBA, float *RGBWT, const float *xy);
void data_more(const unsigned *dim, const float *xlim, const float *ylim, const float *RGBA, float *RGBWT, const float *xy);
void kernel_data_circle(const unsigned *dim, const float *radius, float *blurred_RGBWT, const float *RGBWT);
void kernel_data_gauss(const unsigned *dim, float *blurred_RGBWT, const float *RGBWT, const float *approx_limit, const float *sigma);


//helper methods
float blur(const float *kernel, const float *histogram, const unsigned *dim, const size_t x, const size_t y);
void create_gauss(float *kernel, const size_t size, const float sigma);

#endif
