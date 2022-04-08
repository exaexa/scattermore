#include <stdio.h>
#include <math.h>
#include "kernels.h"

//apply blurring for current point
//kernel is symmetric
float
use_kernel_histogram(const float *kernel,
                     const float *histogram,
                     const unsigned *dim,
                     const size_t x,
                     const size_t y)
{
    float sum = 0;
    const size_t out_size_x = dim[0];
    const size_t out_size_y = dim[1];
    const int radius = dim[2];
    const size_t kernel_size = 2 * radius + 1;


    int i;
    for(i = -radius; i <= radius; ++i)
    {
        int j;
        for(j = -radius; j <= radius; ++j)
        {
            int histogram_index = (x + j) * out_size_y + (y + i);
            int kernel_index = (radius + j) * kernel_size + (radius + i);

            if(y + i >= 0 && y + i < out_size_y && x + j >= 0 && x + j < out_size_x)
                sum += histogram[histogram_index] * kernel[kernel_index];  //else add nothing (zero border padding)
        }
    }

    return sum;
}
