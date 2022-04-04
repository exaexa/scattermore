#include <stdio.h>
#include "kernels.h"

//blur histogram using square kernel of ones
void
kernel_square_histogram(const unsigned *dim,
                        const float *kernel,
                        float *blurred_histogram,
                        const float *histogram)
{
    const size_t size_out_y = dim[0];
    const size_t size_out_x = dim[1];
	
    size_t i;
    for(i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for(j = 0; j < size_out_x; ++j)
        {
            blurred_histogram[j * size_out_y + i] = apply_kernel(kernel, histogram, dim, j, i); //blurring of given point
        }
    }  
}
