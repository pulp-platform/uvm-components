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
// Date: 14.5.2017
// Description: Fetch FIFO Golden Model

// Read 32 bit instruction, separate and re-align them
typedef struct {
        logic [63:0] address;
        logic [31:0] instr;
        branchpredict_sbe_t bp;
} instruction_queue_entry_t;

class fetch_fifo_model;

    logic [15:0] unaligned_part;
    int          is_unaligned = 0;
    logic [63:0] unaligend_address;

    instruction_queue_entry_t instruction_queue[$];

    function void put(logic [63:0] address, logic [31:0] instr, branchpredict_sbe_t bp);
        instruction_queue_entry_t param;

        if (is_unaligned == 0) begin
            // we've got a compressed instruction
            if (instr[1:0] != 2'b11) begin
                param.address = address;
                param.instr   = {16'b0, instr[15:0]};
                param.bp      = bp;

                instruction_queue.push_back(param);
                // the upper part is a unaligned 32 bit instruction
                if (instr[17:16] == 2'b11) begin
                    unaligend_address = {address[63:2], 2'b10};
                    is_unaligned      = 1;
                    unaligned_part    = instr[31:16];
                // there is another compressed instruction
                // don't include if branch prediction predicted a compressed
                // branch in the first instruction part
                end else if (!(bp.predict_taken && bp.valid && bp.is_lower_16)) begin
                    param.address = {address[63:2], 2'b10};
                    param.instr   = instr[31:16];
                    param.bp      = bp;
                    instruction_queue.push_back(param);
                end
            // normal instruction
            end else begin
                param.address = address;
                param.instr   = instr;
                param.bp      = bp;
                instruction_queue.push_back(param);
            end
        // the last generation iteration produced an outstanding instruction
        end else begin
            param.address = unaligend_address;
            param.instr   = {instr[15:0], unaligned_part};
            param.bp      = bp;
            instruction_queue.push_back(param);
            // there is another compressed instruction
            // don't include if branch prediction predicted a compressed
            // branch in the first instruction part
            if (instr[17:16] != 2'b11) begin
                if (!(bp.predict_taken && bp.valid && bp.is_lower_16)) begin
                    param.address = {address[63:2], 2'b10};
                    param.instr   = instr[31:16];
                    param.bp      = bp;
                    instruction_queue.push_back(param);
                end
                is_unaligned = 0;
            end else begin
                // again we have an unaligned instruction
                param.address = {address[63:2], 2'b10};
                is_unaligned = 1;
                unaligned_part = instr[31:16];
            end
        end
    endfunction : put

    function instruction_queue_entry_t pull();
        return instruction_queue.pop_front();
    endfunction : pull

    function flush();
        for (int i = 0; i < instruction_queue.size(); i++) begin
            instruction_queue.delete(i);
        end
    endfunction : flush

endclass : fetch_fifo_model
