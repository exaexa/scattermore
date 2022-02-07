#include <stdio.h>
#include <math.h>

//blur histogram using square kernel of ones
void
kernel_data_circle(const unsigned *dim,
		    float *radius,
	            float *matrix,
	            const float *rgbwt)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], size_out = size_out_y * size_out_x, offset_R = 0, 
	             offset_G = size_out, offset_B = offset_G * 2, offset_W = offset_G * 3, offset_T = offset_G * 4;
	             
	const int int_radius = ceil(*radius);
		     
	const float squared_radius = (*radius) * (*radius);
	
	size_t i;
	for(i = 0; i < size_out_y; ++i)
	{
	  size_t j;
	  for(j = 0; j < size_out_x; ++j)
	  {

	  	int x;
	  	for(x = -int_radius; x <= int_radius; ++x)
	  	{
	  	  int y;
	  	  for(y = -int_radius; x <= int_radius; ++y)
	  	  {
	  	  	if(x*x + y*y > squared_radius)
	  	  		continue;
	  	  		
	  	  	int x_shift = j + x;
	  	  	int y_shift = i + y;
	  	  	
	  	  	if(x_shift < 0 || x_shift >= size_out_x || y_shift < 0 || y_shift >= size_out_y)
	  	  		continue;
	  	  			
	  	  	size_t offset = x_shift*size_out_y + y_shift;	
	  	  	matrix[offset + offset_R] += rgbwt[offset + offset_R];
	  	  	matrix[offset + offset_G] += rgbwt[offset + offset_G];
	  	  	matrix[offset + offset_B] += rgbwt[offset + offset_B];
	  	  	matrix[offset + offset_W] += rgbwt[offset + offset_W];
	  	  	matrix[offset + offset_T] *= rgbwt[offset + offset_T];
	  	  }
	  	}
	  }
	}  
}
