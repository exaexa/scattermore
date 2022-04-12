#ifndef SCATTERS_H_
#define SCATTERS_H_
#include <stdio.h>

void
scatter_histogram(const unsigned *pn,
                  const unsigned *size_out,
                  unsigned *histogram,
                  const float *xlim,
                  const float *ylim,
                  const float *xy);
void
histogram_to_rgbwt(const unsigned *dim,
                   float *RGBWT,
                   const float *pallete,
                   const float *histogram);
void
scatter_singlecolor_rgbwt(const unsigned *dim,
                          const float *xlim,
                          const float *ylim,
                          const float *RGBA,
                          float *RGBWT,
                          const float *xy);
void
scatter_multicolor_rgbwt(const unsigned *dim,
                         const float *xlim,
                         const float *ylim,
                         const float *RGBA,
                         float *RGBWT,
                         const float *xy);
void
scatter_indexed_rgbwt(const unsigned *dim,
                      const float *xlim,
                      const float *ylim,
                      const float *palette,
                      float *RGBWT,
                      const unsigned *map,
                      const float *xy);

#endif
