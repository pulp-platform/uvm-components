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
// Date: 8.5.2017
// Description: Core Interface

`ifndef CORE_IF_SV
`define CORE_IF_SV
interface core_if (
        input clk
    );

    wire clock_en;
    wire test_en;
    wire fetch_enable;
    wire core_busy;
    wire [63:0] boot_addr;
    wire [3:0] core_id;
    wire [5:0] cluster_id;
    wire irq;
    wire [4:0] irq_id;
    wire irq_ack;
    wire irq_sec;
    wire sec_lvl;

   clocking mck @(posedge clk);
        output clock_en, test_en, fetch_enable, boot_addr, core_id, cluster_id, irq, irq_id, irq_sec;
        input  core_busy, sec_lvl, irq_ack;
   endclocking

   clocking pck @(posedge clk);
        input  clock_en, test_en, fetch_enable, boot_addr, core_id, cluster_id, irq, irq_id, irq_sec, core_busy, sec_lvl, irq_ack;
   endclocking

endinterface
`endif
