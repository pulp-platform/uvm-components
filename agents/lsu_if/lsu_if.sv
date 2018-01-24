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
// Date: 02.05.2017
// Description: LSU interface

// Guard statement proposed by "Easier UVM" (doulos)
`ifndef LSU_IF_SV
`define LSU_IF_SV
import ariane_pkg::*;

interface lsu_if #(
        parameter int OPERAND_SIZE = 64
    )
    (
        input clk
    );

    fu_op                         operator;          // FU operation
    wire [OPERAND_SIZE-1:0]       operand_a;         // Operand A
    wire [OPERAND_SIZE-1:0]       operand_b;         // Operand B
    wire [OPERAND_SIZE-1:0]       imm;               // Operand B
    wire [OPERAND_SIZE-1:0]       result;            // Result
    wire [TRANS_ID_BITS-1:0]      lsu_trans_id_id;   // transaction id from ID
    wire [TRANS_ID_BITS-1:0]      lsu_trans_id_wb;   // transaction id to WB
    // LSU control signals
    wire                          commit;
    wire                          source_valid;      // Source operands are valid
    wire                          result_valid;      // Result is valid, ready to accept new request
    wire                          ready;             // Sink is ready
    // exceptions
    wire [$bits(exception_t)-1:0] exception;

    // FU interface configured as master
    clocking mck @(posedge clk);
        default input #1ns output #1ns;
        output operator, operand_a, operand_b, imm, source_valid, commit, lsu_trans_id_id;
        input  result, lsu_trans_id_wb, result_valid, ready, exception;
    endclocking
    // FU interface configured as slave
    clocking sck @(posedge clk);
        default input #1ns output #1ns;
        input  operator, operand_a, operand_b, imm, source_valid, commit, lsu_trans_id_id;
        output result, lsu_trans_id_wb, result_valid, ready, exception;
    endclocking
    // FU interface configured in passive mode
    clocking pck @(posedge clk);
        input operator, operand_a, operand_b, imm, source_valid, commit, lsu_trans_id_id,
              result, lsu_trans_id_wb, result_valid, ready, exception ;
    endclocking

    modport master  (clocking mck);
    modport slave   (clocking sck);
    modport passive (clocking pck);

endinterface
`endif
