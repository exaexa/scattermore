#include <stdio.h>
#include <math.h>

//blur data using its RGBWT matrix with gaussian kernel, expands smooth gaussian neighborhoods
void
kernel_data_gauss(const unsigned *dim,
	          float *blurred_RGBWT,
	          const float *RGBWT,
	          const float *approx_limit,
	          const float *sigma)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], size_out = size_out_y * size_out_x, offset_R = 0, 
	             offset_G = size_out, offset_B = offset_G * 2, offset_W = offset_G * 3, offset_T = offset_G * 4;
	
	const float int_radius = ceil((*sigma) * (*approx_limit));  //size of the kernel
	const float s = 2 * (*sigma) * (*sigma);
	const float s_pi = s * M_PI;
	
	
	size_t i;
	for(i = 0; i < size_out_y; ++i)
	{
	  size_t j;
	  for(j = 0; j < size_out_x; ++j)
	  {
	  	size_t offset = j*size_out_y + i;	

	  	int x;
	  	for(x = -int_radius; x <= int_radius; ++x)  //use neighboring pixels inside of circle with generated radius
	  	{
	  	  int y;
	  	  for(y = -int_radius; y <= int_radius; ++y)
	  	  {
	  	  	int x_shift = j + x;
	  	  	int y_shift = i + y;
	  	  	
	  	  	if(x_shift < 0 || x_shift >= size_out_x || y_shift < 0 || y_shift >= size_out_y)
	  	  		continue;
	  	  		
	  	  	size_t offset_shift = x_shift*size_out_y + y_shift;
	  	  	

	  	  	float W = RGBWT[offset_shift + offset_W];       //extract weight and transparency and find
	  	  	float A = 1 - RGBWT[offset_shift + offset_T];
	  	  	float R, G, B;
	  	  	
	  	  	if(RGBWT[offset_shift + offset_W] != 0)	//find R, G, B values
	  	  	{
				R = RGBWT[offset_shift + offset_R] / W;
				G = RGBWT[offset_shift + offset_G] / W;
				B = RGBWT[offset_shift + offset_B] / W;
	  	  	}
	  	  	else
	  	  		R = G = B = 0;


	  	  	float r = x*x + y*y;
	  	  	float gauss_A = A * ((exp(-r / s)) / s_pi);
	  	  	
	  	  					
	  	  	blurred_RGBWT[offset + offset_R] += R * gauss_A;
	  	  	blurred_RGBWT[offset + offset_G] += G * gauss_A;
	  	  	blurred_RGBWT[offset + offset_B] += B * gauss_A;
	  	  	blurred_RGBWT[offset + offset_W] += gauss_A;
	  	  	blurred_RGBWT[offset + offset_T] *= 1 - gauss_A;
	  	  }
	  	}
	  }
	}  
}
