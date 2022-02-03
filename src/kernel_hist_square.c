#include <stdio.h>
#include "header.h"

//blur histogram using square kernel of ones
void
kernel_hist_square(const unsigned *dim,
	            const float *kernel,
	            float *matrix,
	            const float *hist)
{
	const size_t rows = dim[0], cols = dim[1];
	
	size_t i;
	for(i = 0; i < rows; ++i)
	{
	  size_t j;
	  for(j = 0; j < cols; ++j)
	  {
	  	matrix[j*rows + i] = blur(kernel, hist, dim, j, i); //blurring of given point
	  }
	}  
}
