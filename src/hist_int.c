#include <stdio.h>

//create histogram from given point coordinates in respect to output size
void
hist_int(const unsigned *pn,
	     const unsigned *size_out,
	     unsigned *histogram,
	     const float *xlim,
	     const float *ylim,
	     const float *xy)
{
	const size_t size_data = *pn;
    const size_t size_out_x = size_out[0];
    const size_t size_out_y = size_out[1];

    const float x_begin = xlim[0];
    const float x_end = xlim[1];
    const float x_bin = (size_out_x - 1) / (x_end - x_begin);

    const float y_begin = ylim[1];
    const float y_end = ylim[0];
    const float y_bin = (size_out_y - 1) / (y_end - y_begin);
        
        
    size_t i;
    for(i = 0; i < size_data; ++i)
    {
        size_t x = (xy[i] - x_begin) * x_bin;  //get new point coordinates for histogram
        size_t y = (xy[i + size_data] - y_begin) * y_bin;

        if(x >= size_out_x || y >= size_out_y)
            continue;

        ++histogram[x * size_out_y + y];
    }
}
