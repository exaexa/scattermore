#include <stdio.h>

//colorize given data (make raster) with color corresponding to each point
void
raster_more(const unsigned *dim,
            const float *xlim,
            const float *ylim,
            float *matrix,
            const float *rgba,
            float *rgba_t,
            const float *xy)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], n = dim[2], size_out = size_out_x * size_out_y,
	             offset_G = size_out, offset_B = offset_G * 2, offset_A = offset_G * 3;
	             
	const float x_begin = xlim[0], x_end = xlim[1], x_bin = (size_out_x - 1) / (x_end - x_begin),
                    y_begin = ylim[1], y_end = ylim[0], y_bin = (size_out_y - 1) / (y_end - y_begin);
	             
		  	
	size_t i; size_t x; size_t y;
	for(i = 0; i < n; ++i)
	{
		x = (xy[i] - x_begin) * x_bin;  //get new point coordinates for result raster
		y = (xy[i+n] - y_begin) * y_bin;
			
		if(x >= size_out_x || y >= size_out_y)
			continue;		
			
		float R = rgba[4 * i + 0];
		float G = rgba[4 * i + 1];
		float B = rgba[4 * i + 2];
		float A = rgba[4 * i + 3];
				
		size_t offset = x*size_out_y + y;   //without alphablending
		matrix[offset] = R;
		matrix[offset + offset_G] = G;  
		matrix[offset + offset_B] = B;
		matrix[offset + offset_A] = A;
	}    

}
