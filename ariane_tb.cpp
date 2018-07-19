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

#include "Variane_testharness.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Variane_testharness__Dpi.h"

#include <stdio.h>
#include <fesvr/dtm.h>
#include <iostream>
#include <string>

// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.
static vluint64_t main_time = 0;

extern dtm_t* dtm;

void handle_sigterm(int sig)
{
  dtm->stop();
}

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;     // converts to double, to match
                                // what SystemC does
}

int main(int argc, char **argv) {
  int ret = 0;

  // const char *vcd_file = "new_debug.vcd";
  const char *vcd_file = NULL;
  Verilated::commandArgs(argc, argv);

  dtm = new dtm_t(argc, argv);
  signal(SIGTERM, handle_sigterm);

  std::unique_ptr<Variane_testharness> top(new Variane_testharness);
  std::unique_ptr<VerilatedVcdC> tfp(new VerilatedVcdC);

  if (vcd_file != NULL) {
    Verilated::traceEverOn(true);
    top->trace (tfp.get(), 99);
    tfp->open (vcd_file);
  }

  top->rst_ni = 0;

  while (!dtm->done()) {

    if (vcd_file != NULL) {
      tfp->dump(main_time);
    }

    if (main_time > 40) {
        top->rst_ni = 1; // de-assert reset
    }

    if ((main_time % 10) == 0) {
        top->clk_i = 1; // toggle clock
    }

    if ((main_time % 10) == 6) {
        top->clk_i = 0;
    }

    top->eval();
    main_time++;

  }

  if (vcd_file != NULL) {
    tfp->close ();
  }

  if (dtm->exit_code()) {
    fprintf(stderr, "*** FAILED *** (code = %d) after %ld cycles\n", dtm->exit_code(), main_time);
    ret = dtm->exit_code();
  } else {
    fprintf(stderr, "Completed after %ld cycles\n", main_time);
  }
  return ret;
}
