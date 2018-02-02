// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.


#ifndef __HTIF_SIMMEM_H
#define __HTIF_SIMMEM_H
#include "Variane_wrapped.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "svdpi.h"
#include "Variane_wrapped__Dpi.h"

#include <map>
#include <fesvr/htif.h>
#include <vector>
#include <string>
#include <memory>
#include <fesvr/context.h>
#include <stdio.h>
#include <queue>


class simmem_t : public htif_t
{
public:
  simmem_t(int argc, char** argv, size_t b, size_t w, size_t d);
  simmem_t(const std::vector<std::string>& args, size_t b, size_t w, size_t d);

  void set_vcd (const char *vcd_file) { this->vcd_file = vcd_file; }
  int run();
  addr_t get_tohost_address();
  addr_t get_fromhost_address();

  vluint64_t main_time;       // Current simulation time

private:
  size_t base;
  size_t width;
  size_t depth;
  std::map<addr_t,std::vector<char> > mem;

  std::queue<bool> flush_req;
  std::queue<bool> flushing;

  void flush_dcache();
  const char * vcd_file;

  void read_chunk(addr_t taddr, size_t len, void* dst);
  void write_chunk(addr_t taddr, size_t len, const void* src);

  size_t chunk_max_size() { return 8; }
  size_t chunk_align() { return 8; }
  void reset() { }

  context_t* host;
  context_t target;

  // htif
  friend void sim_thread_main(void*);
  void main();
  void idle();

};

#endif // __HTIF_SIMMEM_H
