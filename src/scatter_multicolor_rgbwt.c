#include <stdio.h>

//calculate RGBWT matrix with given color for each point
void
scatter_multicolor_rgbwt(const unsigned *dim,
                         const float *xlim,
                         const float *ylim,
                         const float *RGBA,
                         float *RGBWT,
                         const float *xy)
{
    const size_t size_out_x = dim[0];
    const size_t size_out_y = dim[1];
    const size_t size_data = dim[2];
    const size_t size_out = size_out_x * size_out_y;

    const size_t offset_R = size_out * 0;
    const size_t offset_G = size_out * 1;
    const size_t offset_B = size_out * 2;
    const size_t offset_W = size_out * 3;
    const size_t offset_T = size_out * 4;
    const size_t offset_RGBA = 4;

    const float x_begin = xlim[0];
    const float x_end = xlim[1];
    const float x_bin = (size_out_x - 1) / (x_end - x_begin);

    const float y_begin = ylim[1];
    const float y_end = ylim[0];
    const float y_bin = (size_out_y - 1) / (y_end - y_begin);


    size_t i;
    for (i = 0; i < size_data; ++i)
    {
        size_t x = (xy[i] - x_begin) * x_bin;  //get new point coordinates for result raster
        size_t y = (xy[i + size_data] - y_begin) * y_bin;

        if (x >= size_out_x || y >= size_out_y)
            continue;

        float R = RGBA[offset_RGBA * i + 0];
        float G = RGBA[offset_RGBA * i + 1];
        float B = RGBA[offset_RGBA * i + 2];
        float A = RGBA[offset_RGBA * i + 3];

	    size_t offset = x * size_out_y + y;
        RGBWT[offset + offset_R] += R * A;
        RGBWT[offset + offset_G] += G * A;
        RGBWT[offset + offset_B] += B * A;
        RGBWT[offset + offset_W] += A;
        RGBWT[offset + offset_T] *= 1 - A;
    }
}
