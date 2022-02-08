#include <stdio.h>
#include <math.h>

//blur data using its rgba matrix with gaussian kernel, expands smooth gaussian neighborhoods
void
kernel_data_gauss(const unsigned *dim,
	          float *matrix,
	          const float *rgba,
	          const float *approx_limit,
	          const float *sigma)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], size_out = size_out_y * size_out_x, offset_R = 0, 
	             offset_G = size_out, offset_B = offset_G * 2, offset_W = offset_G * 3, offset_A = offset_W, offset_T = offset_G * 4;
	
	const float int_radius = ceil((*sigma) * (*approx_limit));  //size of the kernel square
	const float s = 2 * (*sigma) * (*sigma);
	
	
	size_t i;
	for(i = 0; i < size_out_y; ++i)
	{
	  size_t j;
	  for(j = 0; j < size_out_x; ++j)
	  {
	  	size_t offset = j*size_out_y + i;	

	  	int x;
	  	for(x = -int_radius; x <= int_radius; ++x)
	  	{
	  	  int y;
	  	  for(y = -int_radius; y <= int_radius; ++y)
	  	  {
	  	  	int x_shift = j + x;
	  	  	int y_shift = i + y;
	  	  	
	  	  	if(x_shift < 0 || x_shift >= size_out_x || y_shift < 0 || y_shift >= size_out_y)
	  	  		continue;
	  	  		
	  	  	size_t offset_shift = x_shift*size_out_y + y_shift;
	  	  	float r = x*x + y*y;
	  	  	float gauss_A = rgba[offset_shift + offset_A] * ((exp(-r / s)) / (s * M_PI));
	  	  					
	  	  	matrix[offset + offset_R] += rgba[offset_shift + offset_R] * gauss_A;
	  	  	matrix[offset + offset_G] += rgba[offset_shift + offset_G] * gauss_A;
	  	  	matrix[offset + offset_B] += rgba[offset_shift + offset_B] * gauss_A;
	  	  	matrix[offset + offset_W] += gauss_A;
	  	  	matrix[offset + offset_T] *= 1 - gauss_A;
	  	  }
	  	}
	  }
	}  
}
