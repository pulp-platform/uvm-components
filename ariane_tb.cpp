#include "Variane_wrapped.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "svdpi.h"
#include "Variane_wrapped__Dpi.h"

#include <stdio.h>
#include "simmem.h"
#include <fesvr/htif.h>
#include <fesvr/memif.h>
#include <fesvr/elfloader.h>
#include <fesvr/htif_hexwriter.h>

std::unique_ptr<simmem_t> htif;

extern unsigned long long read_mem (unsigned long long address) {
  // printf("Requesting adress %llx\n", address);
  return htif->memif().read_uint64(address);
}

extern void write_mem (unsigned long long address, unsigned long long data) {
  // htif->memif().write_mem(address)
}

vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
                                // what SystemC does
}

int main(int argc, char **argv) {

  std::vector<std::string> args;

  htif.reset(new simmem_t(argc, argv, 0x80000000, 8, 2097152));

  htif->start();

  Verilated::traceEverOn(true);
  std::unique_ptr<VerilatedVcdC> tfp(new VerilatedVcdC);

  Verilated::commandArgs(argc, argv);
  std::unique_ptr<Variane_wrapped> top(new Variane_wrapped);

  top->trace (tfp.get(), 99);
  tfp->open ("obj_dir/simx.vcd");

  top->rst_ni = 0;
  top->fetch_enable_i = 0;
  top->boot_addr_i = 0x80000000;

  while (sc_time_stamp() < 30000 && !Verilated::gotFinish()) {
    tfp->dump(main_time);

    if (main_time > 40) {
        top->rst_ni = 1; // de-assert reset
        top->fetch_enable_i = 1;
    }

    if ((main_time % 10) == 1) {
        top->clk_i = 1; // toggle clock
    }
    if ((main_time % 10) == 6) {
        top->clk_i = 0;
    }

    top->eval();
    main_time++;

  }

  exit(0);
}
