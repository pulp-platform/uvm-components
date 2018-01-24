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
// Date: 3/18/2017
// Description: Generic functional unit interface (fu if)
//              The interface can be used in Master or Slave mode.

// Guard statement proposed by "Easier UVM" (doulos)
`ifndef ALU_IF__SV
`define ALU_IF__SV
interface fu_if #(parameter int OPERATOR_SIZE = 8, parameter int OPERAND_SIZE = 64)(input clk);
    wire [OPERATOR_SIZE-1:0] operator;          // FU operation
    wire [OPERAND_SIZE-1:0]  operand_a;         // Operand A
    wire [OPERAND_SIZE-1:0]  operand_b;         // Operand B
    wire [OPERAND_SIZE-1:0]  operand_c;         // Operand C

    wire [OPERAND_SIZE-1:0]  result;            // Result
    wire                     comparison_result; // Comparison result
    wire                     valid;             // Result is valid, ready to accept new request
    wire                     ready;             // Sink is ready

    // FU interface configured as master
    clocking mck @(posedge clk);
        input   operator, operand_a, operand_b, operand_c, ready;
        output  result, comparison_result, valid;
    endclocking
    // FU interface configured as slave
    clocking sck @(posedge clk);
        output  operator, operand_a, operand_b, operand_c, ready;
        input  result, comparison_result, valid;
    endclocking
    // FU interface configured in passive mode
    clocking pck @(posedge clk);
        input operator, operand_a, operand_b, operand_c, result, ready;
    endclocking

    modport master  (clocking mck);
    modport slave   (clocking sck);
    modport passive (clocking pck);

endinterface
`endif
