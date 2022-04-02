#include <stdio.h>
#include "header.h"

//blur histogram using square kernel of ones
void
kernel_hist_square(const unsigned *dim,
	           const float *kernel,
	           float *blurred_histogram,
	           const float *histogram)
{
    const size_t size_out_y = dim[0];
    const size_t size_out_x = dim[1];
	
    size_t i;
    for (i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for (j = 0; j < size_out_x; ++j)
        {
            blurred_histogram[j * size_out_y + i] = blur(kernel, histogram, dim, j, i); //blurring of given point
        }
    }  
}
