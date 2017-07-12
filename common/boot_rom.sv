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
    input  logic [63:0] address_i,
    output logic [63:0] data_o
);

    always_comb begin

        data_o = 64'hx;

        case (address_i & (~3'h7))
            64'h1000: data_o = 64'h02028593_00000297;
            64'h1008: data_o = 64'h0182b283_f1402573;
            64'h1010: data_o = 64'hxxxxxxxx_00028067;
            64'h1018: data_o = 64'h00000000_80000000;
        endcase
    end


endmodule
