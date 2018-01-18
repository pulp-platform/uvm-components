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
// Description: Fetch FIFO testbench
//

import ariane_pkg::*;
import fetch_fifo_pkg::*;

module fetch_fifo_tb;

    logic rst_ni, clk_i;
    fetch_fifo_if fetch_fifo_if (clk_i);

    fetch_fifo
    dut (
        .clk_i            ( clk_i                            ),
        .rst_ni           ( rst_ni                           ),
        .flush_i          ( fetch_fifo_if.flush              ),
        .branch_predict_i ( fetch_fifo_if.in_branch_predict  ),
        .in_addr_i        ( fetch_fifo_if.in_addr            ),
        .in_rdata_i       ( fetch_fifo_if.in_rdata           ),
        .in_valid_i       ( fetch_fifo_if.in_valid           ),
        .in_ready_o       ( fetch_fifo_if.in_ready           ),
        .fetch_entry_o    ( fetch_fifo_if.fetch_entry        ),
        .out_valid_o      ( fetch_fifo_if.out_valid          ),
        .out_ready_i      ( fetch_fifo_if.out_ready          )
    );

    initial begin
        clk_i = 1'b0;
        rst_ni = 1'b0;
        repeat(8)
            #10ns clk_i = ~clk_i;

        rst_ni = 1'b1;
        forever
            #10ns clk_i = ~clk_i;
    end

    // simulator stopper, this is suboptimal better go for coverage
    initial begin
        #10000000ns
        $finish;
    end

    program testbench (fetch_fifo_if fetch_fifo_if);

        instruction_stream is    = new;
        fetch_fifo_model   model = new;
        instruction_queue_entry_t iqe;

        initial begin

            fetch_fifo_if.mck.flush              <= 1'b0;
            fetch_fifo_if.mck.in_branch_predict  <= 'b0;
            fetch_fifo_if.mck.in_addr            <= 'b0;
            fetch_fifo_if.mck.in_rdata           <= 'b0;
            fetch_fifo_if.mck.in_valid           <= 'b0;
            fetch_fifo_if.mck.out_ready          <= 'b0;
            wait(rst_ni == 1'b1);

            // Driver
            forever begin
                @(fetch_fifo_if.mck iff fetch_fifo_if.in_ready);

                do begin
                    iqe = is.get_instruction();
                    fetch_fifo_if.mck.in_addr           <= iqe.address;
                    fetch_fifo_if.mck.in_rdata          <= iqe.instr;
                    fetch_fifo_if.mck.in_branch_predict <= iqe.bp;
                    fetch_fifo_if.mck.in_valid          <= 1'b1;
                    @(fetch_fifo_if.mck);
                end while (fetch_fifo_if.mck.in_ready);
                fetch_fifo_if.mck.in_valid <= 1'b0;
            end
        end

    endprogram

    testbench tb(fetch_fifo_if);
endmodule
