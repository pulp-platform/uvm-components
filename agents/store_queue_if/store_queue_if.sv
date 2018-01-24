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
// Date: 28.4.2017
// Description: Store Queue Interface

`ifndef STORE_QUEUE_IF_SV
`define STORE_QUEUE_IF_SV
interface store_queue_if
    #( parameter int ADDRESS_SIZE = 64,
       parameter int DATA_WIDTH = 64
    )
    (
        input clk
    );

   wire                     flush;
   wire                     no_st_pending;
   wire [11:0]              page_offset;
   wire                     page_offset_matches;
   wire                     commit;
   wire                     commit_ready;
   wire                     ready;
   wire                     store_valid;
   wire [ADDRESS_SIZE-1:0]  store_paddr;
   wire [DATA_WIDTH-1:0]    store_data;
   wire [DATA_WIDTH/8-1:0]  store_be;

   clocking mck @(posedge clk);
        output flush, commit, store_valid, page_offset, store_paddr, store_data, store_be;
        input  ready, commit_ready, page_offset_matches, no_st_pending;

   endclocking


   clocking pck @(posedge clk);
     input flush, commit, ready, page_offset, page_offset_matches, store_valid, store_paddr, commit_ready,
            store_data, store_be, no_st_pending;
   endclocking

endinterface
`endif
