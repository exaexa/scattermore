#include <stdio.h>

//colorize histogram with given color palette
void
hist_colorize(const unsigned *dim,
	      unsigned *matrix,
	      const unsigned *palette,
	      const float *hist)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], size_palette = dim[2], size_hist = size_out_y * size_out_x,
	             offset_G = size_hist, offset_B = offset_G * 2, offset_A = offset_G * 3;
	const float bin = 1.0/size_palette;
	
	size_t i;
	for(i = 0; i < size_out_y; ++i)
	{
	  size_t j;
	  for(j = 0; j < size_out_x; ++j)
	  {
	  	float hist_value = hist[j*size_out_y + i];
	  	size_t palette_index = ((size_t)(hist_value / bin));  //determining column in palette
	  	
	  	if(palette_index == size_palette) --palette_index;
	  	
	  	size_t R = palette[4 * palette_index + 0];
	  	size_t G = palette[4 * palette_index + 1];
	  	size_t B = palette[4 * palette_index + 2];
	  	size_t A = palette[4 * palette_index + 3];
	  	
	  	size_t offset = j*size_out_y + i;
	  	matrix[offset] = R;
	  	matrix[offset + offset_G] = G;
	  	matrix[offset + offset_B] = B;
	  	matrix[offset + offset_A] = A;
	  }
	}    

}
