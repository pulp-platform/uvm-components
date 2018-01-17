// See LICENSE for license details.

#ifndef __HTIF_SIMMEM_H
#define __HTIF_SIMMEM_H

#include <map>
#include <fesvr/htif.h>
#include <vector>
#include <string>
#include <memory>
#include <fesvr/context.h>
#include <stdio.h>


class simmem_t : public htif_t
{
public:
  simmem_t(int argc, char** argv, size_t b, size_t w, size_t d);
private:
  size_t base;
  size_t width;
  size_t depth;
  std::map<addr_t,std::vector<char> > mem;

  void read_chunk(addr_t taddr, size_t len, void* dst);
  void write_chunk(addr_t taddr, size_t len, const void* src);

  size_t chunk_max_size() { return 8; }
  size_t chunk_align() { return 8; }
  void reset() { }

};

#endif // __HTIF_SIMMEM_H
