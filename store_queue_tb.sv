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
// Description: Store Queue Testbench

module store_queue_tb;
    import uvm_pkg::*;
    import store_queue_lib_pkg::*;

    logic rst_ni, clk;
    logic store_valid;
    logic slave_data_gnt;

    mem_if         slave(clk);
    store_queue_if store_queue(clk);

    logic [43:0] tag;
    logic [11:0] index;

    assign slave.address = {tag, index};

    store_buffer dut (
        .clk_i                 ( clk                                          ),
        .rst_ni                ( rst_ni                                       ),
        .flush_i               ( store_queue.flush                            ),

        .no_st_pending_o       (                                              ),
        .page_offset_i         ( store_queue.page_offset                      ),
        .page_offset_matches_o ( store_queue.page_offset_matches              ),
        .commit_i              ( store_queue.commit                           ),
        .commit_ready_o        ( store_queue.commit_ready                     ),
        .ready_o               ( store_queue.ready                            ),
        .valid_i               ( store_queue.store_valid && store_queue.ready ),
        .paddr_i               ( store_queue.store_paddr                      ),
        .data_i                ( store_queue.store_data                       ),
        .be_i                  ( store_queue.store_be                         ),

        .address_index_o       ( index                                        ),
        .address_tag_o         ( tag                                          ),
        .data_wdata_o          ( slave.data_wdata                             ),
        .data_req_o            ( slave.data_req                               ),
        .data_we_o             ( slave.data_we                                ),
        .data_be_o             ( slave.data_be                                ),
        .kill_req_o            (                                              ), // this field has no meaning regarding the store interface
        .tag_valid_o           (                                              ), // this field has no meaning regarding the store interface
        .data_gnt_i            ( slave.data_gnt & slave.data_req              ),
        .data_rvalid_i         ( slave.data_rvalid                            )
    );

    initial begin
        clk = 1'b0;
        rst_ni = 1'b0;
        repeat(8)
            #10ns clk = ~clk;

        rst_ni = 1'b1;
        forever
            #10ns clk = ~clk;
    end

    program testbench (mem_if slave, store_queue_if store_queue);
        initial begin
            // register the interfaces
            uvm_config_db #(virtual store_queue_if)::set(null, "uvm_test_top", "store_queue_if", store_queue);
            uvm_config_db #(virtual mem_if)::set(null, "uvm_test_top", "mem_if", slave);
            // print the topology
            uvm_top.enable_print_topology = 1;
            // Start UVM test
            run_test();
        end
    endprogram

    testbench tb(slave, store_queue);
endmodule
