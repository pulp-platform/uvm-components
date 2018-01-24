// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 24.4.2017
// Description: FIFO interface

`ifndef FIFO_IF_SV
`define FIFO_IF_SV
interface fifo_if #(parameter type dtype = logic[7:0])
                   (input clk);

   wire   full;
   wire   empty;
   dtype  wdata;
   wire   push;
   dtype  rdata;
   wire   pop;

   clocking mck @(posedge clk);
        input  full, empty, rdata;
        output  wdata, push, pop;
   endclocking

   clocking sck @(posedge clk);
        input  wdata, push, pop;
        output full, empty, rdata;
   endclocking

   clocking pck @(posedge clk);
        input  wdata, push, pop, full, empty, rdata;
   endclocking

endinterface
`endif
