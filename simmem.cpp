// See LICENSE for license details.

#include <iostream>
#include <assert.h>
#include "simmem.h"

simmem_t::simmem_t(int argc, char** argv, size_t b, size_t w, size_t d)
  : htif_t(argc, argv), base(b), width(w), depth(d)
{
}

void simmem_t::read_chunk(addr_t taddr, size_t len, void* vdst)
{
  taddr -= base;

  assert(len % chunk_align() == 0);
  assert(taddr < width*depth);
  assert(taddr+len <= width*depth);

  uint8_t* dst = (uint8_t*)vdst;
  while(len)
  {
    if(mem[taddr/width].size() == 0)
      mem[taddr/width].resize(width,0);

    for(size_t j = 0; j < width; j++)
      dst[j] = mem[taddr/width][j];

    len -= width;
    taddr += width;
    dst += width;
  }
}

void simmem_t::write_chunk(addr_t taddr, size_t len, const void* vsrc)
{
  taddr -= base;

  assert(len % chunk_align() == 0);
  assert(taddr < width*depth);
  assert(taddr+len <= width*depth);

  const uint8_t* src = (const uint8_t*)vsrc;
  while(len)
  {
    if(mem[taddr/width].size() == 0)
      mem[taddr/width].resize(width,0);

    for(size_t j = 0; j < width; j++)
      mem[taddr/width][j] = src[j];

    len -= width;
    taddr += width;
  }
}
