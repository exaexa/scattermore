#include <stdio.h>
#include "kernels.h"

//blur histogram using kernel of ones
void
kernel_gauss_histogram(const unsigned *dim,
                       float *blurred_histogram,
                       const float *histogram,
                       const float *sigma)
{
    const size_t size_out_y = dim[0];
    const size_t size_out_x = dim[1];
    const size_t size_kernel = dim[2];
    float kernel[size_kernel * size_kernel];

    create_gauss(kernel, size_kernel, *sigma);
	
    size_t i;
    for (i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for (j = 0; j < size_out_x; ++j)
        {
            blurred_histogram[j * size_out_y + i] = apply_kernel(kernel, histogram, dim, j, i); //blurring of given point
        }
    }    
}
