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
// Date: 23.05.2017
// Description: Load Store Unit, handles address calculation and memory interface signals

module core_mem #(
        parameter logic [63:0] DRAM_BASE = 64'h80000000
    )(
    input logic clk_i,   // Clock
    input logic rst_ni,  // Asynchronous reset active low

     // Instruction memory/cache
    input  logic [63:0]              instr_if_address_i,
    input  logic                     instr_if_data_req_i,
    output logic                     instr_if_data_gnt_o,
    output logic                     instr_if_data_rvalid_o,
    output logic [63:0]              instr_if_data_rdata_o,
    // Data memory/cache
    input  logic [63:0]              data_if_address_i,
    input  logic                     data_if_data_req_i,
    input  logic [7:0]               data_if_data_be_i,
    output logic                     data_if_data_gnt_o,
    output logic                     data_if_data_rvalid_o,
    output logic [63:0]              data_if_data_rdata_o,
    input  logic [63:0]              data_if_data_wdata_i,
    input  logic                     data_if_data_we_i
);
    // we always grant the access
    localparam ADDRESS_WIDTH = 24;

    logic [63:0] instr_address_q;
    logic [63:0] fetch_data_ram, fetch_data_rom;

    logic [55:0] data_address_q;
    logic [63:0] data_ram, data_rom;

    // look at the address of the previous cycle to determine what to return
    assign instr_if_data_rdata_o = (instr_address_q >= DRAM_BASE) ? fetch_data_ram : fetch_data_rom;
    assign data_if_data_rdata_o = (data_address_q >= DRAM_BASE) ? data_ram : data_rom;

    dp_ram  #(
        .ADDR_WIDTH    ( ADDRESS_WIDTH                                      ),
        .DATA_WIDTH    ( 64                                                 )
    ) ram_i (
        .clk           ( clk_i                                              ),
        .en_a_i        ( 1'b1                                               ),
        .addr_a_i      ( instr_if_address_i[ADDRESS_WIDTH-1+3:3]            ),
        .wdata_a_i     (                                                    ), // not connected
        .rdata_a_o     ( fetch_data_ram                                     ),
        .we_a_i        ( 1'b0                                               ), // r/o interface
        .be_a_i        (                                                    ),
        // data RAM
        .en_b_i        ( data_if_data_req_i                                 ),
        .addr_b_i      ( data_if_address_i[ADDRESS_WIDTH-1+3:3]             ),
        .wdata_b_i     ( data_if_data_wdata_i                               ),
        .rdata_b_o     ( data_ram                                           ),
        .we_b_i        ( ((data_if_address_i >= DRAM_BASE) ? data_if_data_we_i : 1'b0) ),
        .be_b_i        ( data_if_data_be_i                                  )
    );

    boot_rom instr_boot_rom_i (
        .clk_i     ( clk_i           ),
        .rst_ni    ( rst_ni          ),
        .address_i ( instr_address_q ),
        .data_o    ( fetch_data_rom  ),
        .data_q_o  (                 ),
        .req_i     (                 ),
        .grant_o   (                 ),
        .rvalid_o  (                 )
    );

    boot_rom data_boot_rom_i (
        .clk_i     ( clk_i                        ),
        .rst_ni    ( rst_ni                       ),
        .address_i ( {5'b0, data_address_q, 3'b0} ),
        .data_o    ( data_rom                     ),
        .data_q_o  (                              ),
        .req_i     (                              ),
        .grant_o   (                              ),
        .rvalid_o  (                              )
    );

    // give the grant immediately
    assign data_if_data_gnt_o    = data_if_data_req_i;
    // we always grant the request
    assign instr_if_data_gnt_o   = instr_if_data_req_i;

    // Output the rvalid one cycle later, together with the rdata
    always_ff @(posedge clk_i or negedge rst_ni) begin : proc_
        if(~rst_ni) begin
            instr_if_data_rvalid_o <= 1'b0;
            data_if_data_rvalid_o  <= 1'b0;

            instr_address_q        <= '0;
            data_address_q         <= '0;
        end else begin
            instr_if_data_rvalid_o <= instr_if_data_req_i;
            instr_address_q        <= instr_if_address_i;

            data_if_data_rvalid_o  <= data_if_data_req_i;
            data_address_q         <= data_if_address_i[55:0];
        end
    end
endmodule
