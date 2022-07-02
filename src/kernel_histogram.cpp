
/*
 * This file is part of scattermore.
 *
 * Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
 *               2022 Tereza Kulichova <kulichova.t@gmail.com>
 *
 * scattermore is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * scattermore is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * scattermore. If not, see <https://www.gnu.org/licenses/>.
 */

#include "kernels.h"

#include <cmath>
#include <stddef.h>
#include <thread>
#include <vector>

using namespace std;

// blur histogram using given kernel

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

  size_t num_threads = dim[3];
  if (num_threads == 0)
    num_threads = thread::hardware_concurrency();

  vector<thread> list_threads(num_threads);
  const size_t block_size_y = round(size_out_y / (float)num_threads);

  auto thread_code = [&](size_t current_range_y) {
    size_t i;
    for (i = current_range_y; i < current_range_y + block_size_y; ++i) {
      size_t j;
      for (j = 0; j < size_out_x; ++j) {
        float sum = 0;

        int x;
        for (x = -radius; x <= radius;
             ++x) { // blurring region around given point
          int y;
          for (y = -radius; y <= radius; ++y) {
            int histogram_index = (j + x) * size_out_y + (i + y);
            float kernel_value =
              kernel[(radius + x) * kernel_size + (radius + y)];

            if (i + y >= 0 && i + y < size_out_y && j + x >= 0 &&
                j + x < size_out_x)
              sum += histogram[histogram_index] *
                     kernel_value; // else add nothing (zero border padding)
          }
        }
        blurred_histogram[j * size_out_y + i] = sum;
      }
    }
  };

  size_t current_range_y = 0;
  for (size_t thread_id = 0; thread_id < num_threads; ++thread_id) {
    list_threads[thread_id] = thread(
      thread_code, current_range_y); // assign part of the bitmap to each thread
    current_range_y += block_size_y;
  }

  for (auto &thread : list_threads)
    thread.join();
}
