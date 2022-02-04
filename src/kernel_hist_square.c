#include <stdio.h>
#include "header.h"

//blur histogram using square kernel of ones
void
kernel_hist_square(const unsigned *dim,
	            const float *kernel,
	            float *matrix,
	            const float *hist)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1];
	
	size_t i;
	for(i = 0; i < size_out_y; ++i)
	{
	  size_t j;
	  for(j = 0; j < size_out_x; ++j)
	  {
	  	matrix[j*size_out_y + i] = blur(kernel, hist, dim, j, i); //blurring of given point
	  }
	}  
}
