#include <stdio.h>

//create histogram from given point coordinates in respect to output size
void
hist_int(const int *pn,
	const int *size_out,
	unsigned *matrix,
	const float *xlim,
	const float *ylim,
	const float *xy)
{
	const size_t n = *pn, size_out_x = size_out[0], size_out_y = size_out[1];

	const float x_begin = xlim[0], x_end = xlim[1], x_bin = (size_out_x - 1) / (x_end - x_begin),
                    y_begin = ylim[1], y_end = ylim[0], y_bin = (size_out_y - 1) / (y_end - y_begin);
        
        
        unsigned x;
        unsigned y;
        size_t i;   
                 
        for(i = 0; i < n; ++i)
        {
        	x = (xy[i] - x_begin) * x_bin;  //get new point coordinates for histogram
        	y = (xy[i+n] - y_begin) * y_bin;
        	
        	if(x >= size_out_x || y >= size_out_y)
        		continue;
        		
        	++matrix[y*size_out_x + x];
        }

}
