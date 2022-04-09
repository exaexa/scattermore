#include <stdio.h>
#include <math.h>
#include "kernels.h"

//blur data using its RGBWT matrix with given kernel
void
kernel_rgbwt(const unsigned *dim,
             const float *kernel,
             float *blurred_RGBWT,
             const float *RGBWT)
{
    const size_t size_out_x = dim[0];
    const size_t size_out_y = dim[1];
    const int radius = dim[2];
    const size_t size_kernel = radius * 2 + 1;
    const size_t size_out = size_out_x * size_out_y;

    const size_t offset_R = size_out * 0;
    const size_t offset_G = size_out * 1;
    const size_t offset_B = size_out * 2;
    const size_t offset_W = size_out * 3;
    const size_t offset_T = size_out * 4;

    size_t i;
    for(i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for(j = 0; j < size_out_x; ++j)
        {
            size_t offset = j * size_out_y + i;

            float R = 0, G = 0, B = 0, W = 0, T = 1;

            int x;
            for(x = -radius; x <= radius; ++x)
            {
                int y;
                for(y = -radius; y <= radius; ++y)
                {
                    int x_shift = j + x;
                    int y_shift = i + y;

                    if(x_shift < 0 || x_shift >= size_out_x || y_shift < 0 || y_shift >= size_out_y)
                        continue;

                    size_t offset_shift = x_shift * size_out_y + y_shift;

                    float kernel_val = kernel[(radius + x) * size_kernel + (radius + y)];

                    R += RGBWT[offset_shift + offset_R] * kernel_val;
                    G += RGBWT[offset_shift + offset_G] * kernel_val;
                    B += RGBWT[offset_shift + offset_B] * kernel_val;
                    W += RGBWT[offset_shift + offset_W] * kernel_val;
                    //this is an approximation:
                    T *= 1 - ((1 - RGBWT[offset_shift + offset_T]) * kernel_val);
                }
            }

            blurred_RGBWT[offset + offset_R] = R;
            blurred_RGBWT[offset + offset_G] = G;
            blurred_RGBWT[offset + offset_B] = B;
            blurred_RGBWT[offset + offset_W] = W;
            blurred_RGBWT[offset + offset_T] = T;
        }
    }
}
