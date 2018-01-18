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

#include "svdpi.h"
#include "Variane_wrapped__Dpi.h"

#include <stdio.h>
#include "simmem.h"
#include <fesvr/htif.h>
#include <fesvr/memif.h>
#include <fesvr/htif_hexwriter.h>

std::unique_ptr<simmem_t> htif;
bool stop_sim = false;

extern unsigned long long read_uint64 (unsigned long long address) {
  // printf("Requesting adress %llx\n", address);
  return htif->memif().read_uint64(address);
}

extern void write_uint64 (unsigned long long address, unsigned long long data) {
  // printf("Writing %llx @ %llx\n", data, address);
  htif->memif().write_uint64(address, data);
}

// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

double sc_time_stamp () {       // Called by $time in Verilog
    return htif->main_time;           // converts to double, to match
                                // what SystemC does
}

int main(int argc, char **argv) {

  std::vector<std::string> args;

  htif.reset(new simmem_t(argc, argv, 0x80000000, 8, 2097152));

  htif->start();
  htif->run();

  exit(0);
}
