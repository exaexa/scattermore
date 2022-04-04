#include <stdio.h>

//colorize histogram with given color palette
void
histogram_to_rgbwt(const unsigned *dim,
                   float *RGBWT,
                   const float *palette,
                   const float *histogram)
{
    const size_t size_out_y = dim[0];
    const size_t size_out_x = dim[1];
    const size_t size_palette = dim[2];
    const float bin = 1.0 / size_palette;
    const size_t size_out= size_out_y * size_out_x;

    const size_t offset_R = size_out * 0;
    const size_t offset_G = size_out * 1;
    const size_t offset_B = size_out * 2;
    const size_t offset_W = size_out * 3;
    const size_t offset_T = size_out * 4;

    size_t i;
    for (i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for (j = 0; j < size_out_x; ++j)
        {
            float histogram_value = histogram[j * size_out_y + i];
            size_t palette_index = ((size_t)(histogram_value / bin));  //determining column in palette

            if(palette_index == size_palette)
                  --palette_index;

            float R = palette[4 * palette_index + 0];
            float G = palette[4 * palette_index + 1];
            float B = palette[4 * palette_index + 2];
            float A = palette[4 * palette_index + 3];

            size_t offset = j * size_out_y + i;
            RGBWT[offset + offset_R] = R;
            RGBWT[offset + offset_G] = G;
            RGBWT[offset + offset_B] = B;
            RGBWT[offset + offset_W] = 1;
            RGBWT[offset + offset_T] = 1 - A;
        }
    }
}
