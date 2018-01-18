// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 14.5.2017
// Description: Fetch FIFO interface

`ifndef FETCH_FIFO_IF_SV
`define FETCH_FIFO_IF_SV
import ariane_pkg::*;

interface fetch_fifo_if (
        input clk
    );

    wire                                  flush;
    wire [$bits(branchpredict_sbe_t)-1:0] in_branch_predict;
    wire [63:0]                           in_addr;
    wire [31:0]                           in_rdata;
    wire                                  in_valid;
    wire                                  in_ready;
    wire [$bits(fetch_entry_t)-1:0]       fetch_entry;
    wire                                  out_valid;
    wire                                  out_ready;

   clocking mck @(posedge clk);
        input  in_ready, fetch_entry, out_valid;
        output flush, in_branch_predict, in_addr, in_rdata, in_valid, out_ready;
   endclocking

   clocking pck @(posedge clk);
        input  in_ready, fetch_entry, out_valid,
               flush, in_branch_predict, in_addr, in_rdata, in_valid, out_ready;
   endclocking

endinterface
`endif
