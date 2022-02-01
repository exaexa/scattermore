#include <stdio.h>
#include <math.h>

//apply blurring for current point, symmetric kernel
float 
blur(const float *kernel, 
     const float *data, 
     const int *dim, 
     const size_t x, 
     const size_t y)
{
	float sum = 0;
	const int rows = dim[0], cols = dim[1], size = dim[2], range = size/2;
	
		  
	int i;
	for(i = -range; i <= range; ++i)
	{
	  int j;
	  for(j = -range; j <= range; ++j)
	  {
	  	int data_index = (y+i)*cols + (x+j);
	  	int kernel_index = (range+i)*size + (range+j);
	  	
	  	if(data_index >= 0 && data_index < rows*cols)
			sum = sum + data[data_index]*kernel[kernel_index];  //else add nothing (zero border padding)
	  }
	}
	  
	return sum;
}


//create gaussian filter with given sigma and size
void 
create_gauss(float *kernel, 
             const size_t size, 
             const float sigma)
{
	int range = size/2;
	float s = 2 * sigma * sigma;
	
	int i;
	for(i = -range; i <= range; ++i)
	{
	  int j;
	  for(j = -range; j <= range; ++j)
	  {
	  	int index = (range+i)*size + (range+j);
	  	float r = i*i + j*j;
		kernel[index] = (exp(-r / s)) / (s * M_PI);
	  }
	}
}
