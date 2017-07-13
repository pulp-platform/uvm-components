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
module boot_rom #(
        string fdt_path = "ariane_tb.dtb"
    )
    (
    input  logic [63:0] address_i,
    output logic [63:0] data_o
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
            64'h1000: data_o = 64'h02028593_00000297;
            64'h1008: data_o = 64'h0182b283_f1402573;
            64'h1010: data_o = 64'hxxxxxxxx_00028067;
            // boot address
            64'h1018: data_o = 64'h00000000_80000000;
            // device tree
            default: begin
                data_o = fdt[fdt_address[63:3]];
            end
        endcase
    end

    // read device tree
    initial begin
        int f_byte;
        int f_bin;
        logic [63:0] out;

        if (fdt_path != "") begin
            f_bin = $fopen(fdt_path,"rb");

            f_byte = $fread(fdt, f_bin);

            foreach (fdt[i]) begin
                // reverse bytes
                fdt[i] = { << byte {fdt[i]}};
                // $display("%h", fdt[i]);
          end

        end
    end
endmodule
