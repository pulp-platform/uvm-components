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

#include <assert.h>
#include "simmem.h"

simmem_t::simmem_t(int argc, char** argv, size_t b, size_t w, size_t d)
  : htif_t(argc, argv), base(b), width(w), depth(d) {

}
simmem_t::simmem_t(const std::vector<std::string>& args, size_t b, size_t w, size_t d)
  : htif_t(args), base(b), width(w), depth(d) {

}

void sim_thread_main(void* arg) {
  ((simmem_t*)arg)->main();
}

void simmem_t::main() {

    std::unique_ptr<Variane_wrapped> top(new Variane_wrapped);
    std::unique_ptr<VerilatedVcdC> tfp(new VerilatedVcdC);

    if (this->vcd_file != NULL) {
      Verilated::traceEverOn(true);
      top->trace (tfp.get(), 99);
      tfp->open (this->vcd_file);
    }

    if (this->label != NULL) {
        fprintf(stderr, "%s\n", label);
    }

    top->core_id_i = 0;
    top->cluster_id_i = 0;
    top->rst_ni = 0;
    top->fetch_enable_i = 0;
    top->boot_addr_i = 0x80000000;
    top->flush_req_i = 0;

    while (!Verilated::gotFinish()) {

      if (this->vcd_file != NULL) {
        tfp->dump(main_time);
      }

      if (main_time > 40) {
          top->rst_ni = 1; // de-assert reset
          top->fetch_enable_i = 1;
      }

      if ((main_time % 10) == 0) {
          top->clk_i = 1; // toggle clock
      }

      // Apply
      if ((main_time % 10) == 8) {
        if (!flush_req.empty() && !top->flushing_o) {
          flush_req.pop();
          flushing.push(true);
          top->flush_req_i = 1;
        }
      }

      // Test
      if ((main_time % 10) == 1) {
        if (!flushing.empty()) {
          flushing.pop();
          top->flush_req_i = 0;
        }
      }

      if ((main_time % 10) == 6) {
          top->clk_i = 0;
      }

      if ((main_time % 10) == 0) {
        host->switch_to();
      }


      top->eval();
      main_time++;

    }

    if (this->vcd_file != NULL) {
      tfp->close ();
    }
}

addr_t simmem_t::get_tohost_address() {
  return htif_t::tohost_addr;
}

addr_t simmem_t::get_fromhost_address() {
  return htif_t::fromhost_addr;
}

void simmem_t::flush_dcache() {
  flush_req.push(true);
}

void simmem_t::idle()
{
  target.switch_to();
}

int simmem_t::run()
{
  host = context_t::current();
  target.init(sim_thread_main, this);
  return htif_t::run();
}

void simmem_t::read_chunk(addr_t taddr, size_t len, void* vdst)
{
  taddr -= base;

  assert(len % chunk_align() == 0);
  if (taddr >= width*depth) {
    return;
  }

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
  if (taddr == fromhost_addr) {
    flush_dcache();
  }

  taddr -= base;

  assert(len % chunk_align() == 0);
  if (taddr >= width*depth) {
    return;
  }

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
