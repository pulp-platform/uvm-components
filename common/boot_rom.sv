// Author: Florian Zaruba, ETH Zurich
// Date: 12.07.2017
// Description: Boot ROM, copied from Spike
//
// Copyright (C) 2017 ETH Zurich, University of Bologna
// All rights reserved.
//
// This code is under development and not yet released to the public.
// Until it is released, the code is under the copyright of ETH Zurich and
// the University of Bologna, and may contain confidential and/or unpublished
// work. Any reuse/redistribution is strictly forbidden without written
// permission from ETH Zurich.
//
// Bug fixes and contributions will eventually be released under the
// SolderPad open hardware license in the context of the PULP platform
// (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
// University of Bologna.
//
module boot_rom (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [63:0] address_i,
    output logic [63:0] data_o, // combinatorial output
    output logic [63:0] data_q_o, // sequential output
    input  logic        req_i,
    output logic        grant_o,
    output logic        rvalid_o
);

    // one kilobyte of device tree for now
    logic [63:0] fdt [0:256];
    always_comb begin
        automatic logic [63:0] fdt_address = address_i - 64'h1020;

        data_o = 64'hx;

        // auipc   t0, 0x0
        // addi    a1, t0, 32
        // csrr    a0, mhartid
        // ld      t0, 24(t0)
        // jr      t0
        case (address_i & (~3'h7))
            64'h1000: data_o = 64'h00a2a02345056291;
            64'h1008: data_o = 64'h0202859302fe4285;
            64'h1010: data_o = 64'h00028067f1402573;
            64'h1018: data_o = 64'h0000000000000000;
            // device tree
            default: begin
                data_o = 64'hx; //fdt[fdt_address[63:3]];
            end
        endcase
        // we immediately give a grant - it's a ROM, nothing indeterministic about it
        grant_o = req_i;
    end

    // Sequential Process
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            rvalid_o <= 1'b0;
            data_q_o <= 'x;
        end else begin
            rvalid_o <= req_i;
            data_q_o <= data_o;
        end
    end

endmodule
