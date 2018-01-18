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
// Date: 03/19/2017
// Description: Top level testbench module. Instantiates the top level DUT, configures
//              the virtual interfaces and starts the test passed by +UVM_TEST+
//

module alu_tb;

    import uvm_pkg::*;
    // import the main test class
    import alu_lib_pkg::*;
    import ariane_pkg::*;

    logic clk;
    logic rstn_i;

    localparam OPERATOR_SIZE = 8;
    localparam OPERAND_SIZE = 64;

    fu_if #(OPERATOR_SIZE, OPERAND_SIZE) alu_if (clk);

    // ------------------------
    // DUT - Device Under Test
    // ------------------------
    alu
    dut
    (
        .trans_id_i             (                           ),
        .alu_valid_i            (                           ),
        .operator_i             ( fu_op'(alu_if.operator)   ),
        .operand_a_i            ( alu_if.operand_a          ),
        .operand_b_i            ( alu_if.operand_b          ),
        .result_o               ( alu_if.result             ),
        .alu_valid_o            (                           ),
        .alu_ready_o            (                           ),
        .alu_trans_id_o         (                           )
    );

    initial begin
    // register the ALU interface
    uvm_config_db #(virtual fu_if)::set(null, "uvm_test_top", "fu_vif", alu_if);
    end

    initial begin
        clk = 1'b0;
        rstn_i = 1'b0;
        repeat(8)
            #10ns clk = ~clk;

        rstn_i = 1'b1;

        forever
            #10ns clk = ~clk;
    end

    initial begin
        // print the topology
        uvm_top.enable_print_topology = 1;
        // Start UVM test
        run_test();
    end
endmodule
