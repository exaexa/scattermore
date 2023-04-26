/*
 * This file is part of scattermore.
 *
 * Copyright (C) 2022 Mirek Kratochvil <exa.exa@gmail.com>
 *               2023 Tereza Kulichova <kulichova.t@gmail.com>
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

#include <thread>
#include <vector>

using namespace std;

template<typename i>
constexpr i
n_blocks(i size_out, i block_size)
{
  return (size_out + block_size - 1) / block_size;
}

template<typename F>
void
threaded_foreach_1dblocks(size_t size_out,
                          size_t block_size,
                          size_t num_threads,
                          F func)
{

  if (num_threads == 0)
    num_threads = thread::hardware_concurrency();

  if (num_threads == 1) {
    for (size_t i = 0; i < size_out; ++i)
      func(0, i);
    return;
  }

  // zero blocksize = equal thread split
  size_t num_blocks =
    block_size == 0 ? num_threads : n_blocks(size_out, block_size);

  vector<thread> threads(num_threads);
  for (size_t i = 0; i < num_threads; ++i)
    threads[i] = thread(
      [&](size_t thread_id) {
        for (size_t block_id = thread_id; block_id < num_blocks;
             block_id += num_threads) {
          size_t block_begin = block_id * size_out / num_blocks;
          size_t block_end = (block_id + 1) * size_out / num_blocks;
          for (size_t j = block_begin; j < block_end; ++j)
            func(thread_id, j);
        }
      },
      i);

  for (size_t i = 0; i < num_threads; ++i)
    threads[i].join();
}

template<typename F>
void
threaded_foreach_2dblocks(size_t size_out_x,
                          size_t size_out_y,
                          size_t block_size_x,
                          size_t block_size_y,
                          size_t num_threads,
                          F func)
{
  if (num_threads == 0)
    num_threads = thread::hardware_concurrency();

  size_t num_blocks_x = n_blocks(size_out_x, block_size_x);
  size_t num_blocks_y = n_blocks(size_out_y, block_size_y);
  size_t num_blocks = num_blocks_x * num_blocks_y;

  if (num_threads == 1) {
    for (size_t Y = 0; Y < num_blocks_y; ++Y)
      for (size_t X = 0; X < num_blocks_x; ++X)
        for (size_t y = 0; y < block_size_y; ++y) {
          size_t current_block_pixel_y = Y * block_size_y + y;
          if (current_block_pixel_y >= size_out_y)
            break;
          for (size_t x = 0; x < block_size_x; ++x) {
            size_t current_block_pixel_x = X * block_size_x + x;
            if (current_block_pixel_x >= size_out_x)
              break;
            func(0, current_block_pixel_x, current_block_pixel_y);
          }
        }
    return;
  }

  vector<thread> threads(num_threads);
  for (size_t i = 0; i < num_threads; ++i)
    threads[i] = thread(
      [&](size_t thread_id) {
        for (size_t block_id = thread_id; block_id < num_blocks;
             block_id += num_threads) {
          size_t Y = block_id / num_blocks_x;
          size_t X = block_id % num_blocks_x;
          for (size_t y = 0; y < block_size_y; ++y) {
            size_t current_block_pixel_y = Y * block_size_y + y;
            if (current_block_pixel_y >= size_out_y)
              break;
            for (size_t x = 0; x < block_size_x; ++x) {
              size_t current_block_pixel_x = X * block_size_x + x;
              if (current_block_pixel_x >= size_out_x)
                break;
              func(thread_id, current_block_pixel_x, current_block_pixel_y);
            }
          }
        }
      },
      i);

  for (size_t i = 0; i < num_threads; ++i)
    threads[i].join();
}
