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
// Date: 12.07.2017
// Description: Boot ROM, similar to Spike

module boot_rom #(
    parameter int unsigned DATA_WIDTH = 64
)(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic [63:0]           address_i,
    output logic [DATA_WIDTH-1:0] data_o // combinatorial output
);

    localparam BYTE_OFFSET = $clog2(DATA_WIDTH/8);

    logic [31:0][7:0] mem;
    assign mem = 256'h0000000000000000_00028067f1402573_0202859302fe4285_00a2a02345056291;
    assign data_o = mem[address_i[5:BYTE_OFFSET]+:DATA_WIDTH/8];

endmodule
