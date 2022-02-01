#include <stdio.h>
#include "blur.h"

//blur histogram using kernel of ones
void
kernel_hist_classic(const int *dim,
	            const float *kernel,
	            float *matrix,
	            const float *data)
{
	const size_t rows = dim[0], cols = dim[1], size = dim[2];
	
	size_t i;
	for(i = 0; i < rows; ++i)
	{
	  size_t j;
	  for(j = 0; j < cols; ++j)
	  {
	  	matrix[i*cols + j] = blur(kernel, data, dim, j, i); //blurring of given point
	  }
	}  
}
