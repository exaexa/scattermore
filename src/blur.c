#include <stdio.h>
#include <math.h>

//apply blurring for current point, symmetric kernel
float 
blur(const float *kernel, 
     const float *data, 
     const unsigned *dim, 
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
	  	int data_index = (x+j)*rows + (y+i);
	  	int kernel_index = (range+j)*size + (range+i);
	  	
	  	if(y+i >= 0 && y+i < rows && x+j >= 0 && x+j < cols)
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
	const float s = 2 * sigma * sigma;
	
	int i;
	for(i = -range; i <= range; ++i)
	{
	  int j;
	  for(j = -range; j <= range; ++j)
	  {
	  	int index = (range+j)*size + (range+i);
	  	float r = i*i + j*j;
		kernel[index] = (exp(-r / s)) / (s * M_PI);
	  }
	}
}
