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
#include <iostream>
#include <string>
#include <getopt.h>

#include <fesvr/dtm.h>
#include "remote_bitbang.h"

// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.
static vluint64_t main_time = 0;

extern dtm_t* dtm;
extern remote_bitbang_t * jtag;

void handle_sigterm(int sig)
{
  dtm->stop();
}

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;     // converts to double, to match
                                // what SystemC does
}

static void usage(const char * program_name) {
  printf("Usage: %s [EMULATOR OPTION]... [VERILOG PLUSARG]... [HOST OPTION]... BINARY [TARGET OPTION]...\n",
         program_name);
}

int main(int argc, char **argv) {
  bool verbose;
  unsigned random_seed = (unsigned)time(NULL) ^ (unsigned)getpid();
  uint64_t max_cycles = -1;
  int ret = 0;
  bool print_cycles = false;
  // Port numbers are 16 bit unsigned integers.
  uint16_t rbb_port = 0;
#if VM_TRACE
  FILE * vcdfile = NULL;
  uint64_t start = 0;
#endif
  char ** htif_argv = NULL;

  while (1) {
    static struct option long_options[] = {
      {"cycle-count", no_argument,       0, 'c' },
      {"help",        no_argument,       0, 'h' },
      {"max-cycles",  required_argument, 0, 'm' },
      {"seed",        required_argument, 0, 's' },
      {"rbb-port",    required_argument, 0, 'r' },
      {"verbose",     no_argument,       0, 'V' },
#if VM_TRACE
      {"vcd",         required_argument, 0, 'v' },
      {"dump-start",  required_argument, 0, 'x' },
#endif
      HTIF_LONG_OPTIONS
    };
    int option_index = 0;
#if VM_TRACE
    int c = getopt_long(argc, argv, "-chm:s:r:v:Vx:", long_options, &option_index);
#else
    int c = getopt_long(argc, argv, "-chm:s:r:V", long_options, &option_index);
#endif
    if (c == -1) break;
 retry:
    switch (c) {
      // Process long and short EMULATOR options
      case '?': usage(argv[0]);             return 1;
      case 'c': print_cycles = true;        break;
      case 'h': usage(argv[0]);             return 0;
      case 'm': max_cycles = atoll(optarg); break;
      case 's': random_seed = atoi(optarg); break;
      case 'r': rbb_port = atoi(optarg);    break;
      case 'V': verbose = true;             break;
#if VM_TRACE
      case 'v': {
        vcdfile = strcmp(optarg, "-") == 0 ? stdout : fopen(optarg, "w");
        if (!vcdfile) {
          std::cerr << "Unable to open " << optarg << " for VCD write\n";
          return 1;
        }
        break;
      }
      case 'x': start = atoll(optarg);      break;
#endif
      // Process legacy '+' EMULATOR arguments by replacing them with
      // their getopt equivalents
      case 1: {
        std::string arg = optarg;
        if (arg.substr(0, 1) != "+") {
          optind--;
          goto done_processing;
        }
        if (arg == "+verbose")
          c = 'V';
        else if (arg.substr(0, 12) == "+max-cycles=") {
          c = 'm';
          optarg = optarg+12;
        }
#if VM_TRACE
        else if (arg.substr(0, 12) == "+dump-start=") {
          c = 'x';
          optarg = optarg+12;
        }
#endif
        else if (arg.substr(0, 12) == "+cycle-count")
          c = 'c';

        // If we STILL don't find a legacy '+' argument, it still could be
        // an HTIF (HOST) argument and not an error. If this is the case, then
        // we're done processing EMULATOR and VERILOG arguments.
        else {
          static struct option htif_long_options [] = { HTIF_LONG_OPTIONS };
          struct option * htif_option = &htif_long_options[0];
          while (htif_option->name) {
            if (arg.substr(1, strlen(htif_option->name)) == htif_option->name) {
              optind--;
              goto done_processing;
            }
            htif_option++;
          }
          std::cerr << argv[0] << ": invalid plus-arg (Verilog or HTIF) \""
                    << arg << "\"\n";
          c = '?';
        }
        goto retry;
      }
      case 'P': break; // Nothing to do here, Verilog PlusArg
      // Realize that we've hit HTIF (HOST) arguments or error out
      default:
        if (c >= HTIF_LONG_OPTIONS_OPTIND) {
          optind--;
          goto done_processing;
        }
        c = '?';
        goto retry;
    }
  }

done_processing:
  if (optind == argc) {
    std::cerr << "No binary specified for emulator\n";
    usage(argv[0]);
    return 1;
  }
  int htif_argc = 1 + argc - optind;
  htif_argv = (char **) malloc((htif_argc) * sizeof (char *));
  htif_argv[0] = argv[0];
  for (int i = 1; optind < argc;) htif_argv[i++] = argv[optind++];


  // const char *vcd_file = "new_debug.vcd";
  const char *vcd_file = NULL;
  Verilated::commandArgs(argc, argv);

  jtag = new remote_bitbang_t(0);
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

  while (!dtm->done() && !jtag->done()) {

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
  } else if (jtag->exit_code()) {
    fprintf(stderr, "*** FAILED *** (code = %d, seed %d) after %ld cycles\n", jtag->exit_code(), random_seed, main_time);
    ret = jtag->exit_code();
  } else {
    fprintf(stderr, "Completed after %ld cycles\n", main_time);
  }

  if (dtm) delete dtm;
  if (jtag) delete jtag;

  return ret;
}
