#include <stdio.h>
#include <math.h>

//colorize histogram with given color palette
void
hist_colorize(const int *dim,
	      unsigned *matrix,
	      const unsigned *palette,
	      const float *hist)
{
	const size_t rows = dim[0], cols = dim[1], size_palette = dim[2], size_hist = rows * cols,
	             offset_G = size_hist, offset_B = offset_G * 2, offset_A = offset_G * 3;
	const float bin = 1.0/size_palette;
	
	size_t i;
	for(i = 0; i < rows; ++i)
	{
	  size_t j;
	  for(j = 0; j < cols; ++j)
	  {
	  	float hist_value = hist[j*rows + i];
	  	size_t palette_index = ((size_t)(hist_value / bin));  //determining column in palette
	  	
	  	if(palette_index == size_palette) --palette_index;
	  	
	  	unsigned R = palette[4 * palette_index + 0];
	  	unsigned G = palette[4 * palette_index + 1];
	  	unsigned B = palette[4 * palette_index + 2];
	  	unsigned A = palette[4 * palette_index + 3];
	  	
	  	size_t offset = j*rows + i;
	  	matrix[offset] = R;
	  	matrix[offset + offset_G] = G;
	  	matrix[offset + offset_B] = B;
	  	matrix[offset + offset_A] = A;
	  }
	}    

}
