#include <stdio.h>
#include <math.h>
#include "kernels.h"

//apply blurring for current point
//kernel is symmetric
float 
apply_kernel(const float *kernel,
             const float *histogram,
             const unsigned *dim,
             const size_t x,
             const size_t y)
{
    float sum = 0;
    const size_t rows = dim[0];
    const size_t cols = dim[1];
    const size_t size = dim[2];
    const int range = size / 2;
	
		  
    int i;
    for(i = -range; i <= range; ++i)
    {
        int j;
        for(j = -range; j <= range; ++j)
        {
            int histogram_index = (x + j) * rows + (y + i);
            int kernel_index = (range + j) * size + (range + i);

            if(y + i >= 0 && y + i < rows && x + j >= 0 && x + j < cols)
                sum = sum + histogram[histogram_index] * kernel[kernel_index];  //else add nothing (zero border padding)
        }
    }
	  
    return sum;
}