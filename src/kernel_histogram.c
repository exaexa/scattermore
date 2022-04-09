#include <stdio.h>
#include "kernels.h"

//blur histogram using square kernel of total weight 1
void
kernel_histogram(const unsigned *dim,
                 const float *kernel,
                 float *blurred_histogram,
                 const float *histogram)
{
    const size_t size_out_x = dim[0];
    const size_t size_out_y = dim[1];
    const int radius = dim[2];
    const size_t kernel_size = 2 * radius + 1;

    size_t i;
    for(i = 0; i < size_out_y; ++i)
    {
        size_t j;
        for(j = 0; j < size_out_x; ++j)
        {
            float sum = 0;

            int x;
            for(x = -radius; x <= radius; ++x)
            {
                int y;
                for(y = -radius; y <= radius; ++y)
                {
                    int histogram_index = (j + x) * size_out_y + (i + y);
                    int kernel_index = (radius + x) * kernel_size + (radius + y);

                    if(i + y >= 0 && i + y < size_out_y && j + x >= 0 && j + x < size_out_x)
                        sum += histogram[histogram_index] * kernel[kernel_index];  //else add nothing (zero border padding)
                }
            }
            blurred_histogram[j * size_out_y + i] = sum;
        }
    }
}
