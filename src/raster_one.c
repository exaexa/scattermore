#include <stdio.h>

//calculate RGBWT matrix with one given color
void
raster_one(const unsigned *dim,
            const float *xlim,
            const float *ylim,
            const float *rgba,
            float *rgbwt,
            const float *xy)
{
	const size_t size_out_y = dim[0], size_out_x = dim[1], n = dim[2], size_out = size_out_x * size_out_y,
	             offset_R = 0, offset_G = size_out, offset_B = offset_G * 2, offset_W = offset_G * 3, offset_T = offset_G * 4;
	             
	const float x_begin = xlim[0], x_end = xlim[1], x_bin = (size_out_x - 1) / (x_end - x_begin),
                    y_begin = ylim[1], y_end = ylim[0], y_bin = (size_out_y - 1) / (y_end - y_begin);
	             

	float R = rgba[0];
	float G = rgba[1];
	float B = rgba[2];
	float A = rgba[3];

	size_t i;
	for(i = 0; i < n; ++i)
	{
		size_t x = (xy[i] - x_begin) * x_bin;  //get new point coordinates for result raster
		size_t y = (xy[i+n] - y_begin) * y_bin;
			
		if(x >= size_out_x || y >= size_out_y)
			continue;		
				
		size_t offset = x*size_out_y + y;
		rgbwt[offset + offset_R] += R*A;
		rgbwt[offset + offset_G] += G*A;  
		rgbwt[offset + offset_B] += B*A;
		rgbwt[offset + offset_W] += A;
		rgbwt[offset + offset_T] *= 1-A;
	} 
}
