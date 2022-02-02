#include <stdio.h>
#include "header.h"

//blur histogram using kernel of ones
void
kernel_hist_gauss(const int *dim,
	          float *matrix,
	          const float *hist,
	          const float *sigma)
{
	const size_t rows = dim[0], cols = dim[1], size = dim[2];
	
	
	float kernel[size*size];
	create_gauss(kernel, size, sigma);
	
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
