// Author: Florian Zaruba, ETH Zurich
// Date: 04.07.2017
// Description: Top Level Testbench
//
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
`timescale 1ns / 1ps

import uvm_pkg::*;

`include "uvm_macros.svh"

module coreplex_tb;
    import "DPI-C" function chandle read_elf(string fn);
    import "DPI-C" function longint unsigned get_section_address(string symb);
    import "DPI-C" function longint unsigned get_section_size(string symb);
    import "DPI-C" function longint unsigned get_symbol_address(string symb);

    static uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();

    localparam int unsigned CLOCK_PERIOD = 20ns;
    localparam int unsigned RTC_PERIOD = (30.517578us/2);
    logic clk_i;
    logic rst_ni;
    logic rtc_i;

    logic clock_en_i;
    logic test_en_i;
    logic fetch_enable_i;

    uncore dut (
        .clk_i          ( clk_i          ),
        .rtc_i          ( rtc_i          ),
        .clock_en_i     ( clock_en_i     ),
        .rst_ni         ( rst_ni         ),
        .test_en_i      ( 1'b0           ),
        .fetch_enable_i ( fetch_enable_i )
    );

    // ------------------
    // Clocking Process
    // ------------------
    initial begin
        clk_i = 1'b0;
        rst_ni = 1'b0;

        repeat(8)
            #(CLOCK_PERIOD/2) clk_i = ~clk_i;

        rst_ni = 1'b1;

        forever begin
            #(CLOCK_PERIOD/2) clk_i = 1'b1;
            #(CLOCK_PERIOD/2) clk_i = 1'b0;
        end
    end

    initial begin
        rtc_i = 1'b0;
        forever begin
            #(RTC_PERIOD) rtc_i = 1'b1;
            #(RTC_PERIOD) rtc_i = 1'b0;
        end
    end

    // ------------------
    // Fetch Enable
    // ------------------
    initial begin

        fetch_enable_i = 1'b0;
        wait (20ns);
        wait (rst_ni);
        wait (200ns);
        fetch_enable_i = 1'b1;

    end
    task preload_memories();
        string plus_args [$];

        string file;
        string file_name;
        string base_dir;
        string test;
        // offset the temporary RAM
        logic [63:0] rmem [16384];

        // get the file name from a command line plus arg
        void'(uvcl.get_arg_value("+BASEDIR=", base_dir));
        void'(uvcl.get_arg_value("+ASMTEST=", file_name));

        file = {base_dir, "/", file_name};

        `uvm_info("Program Loader", $sformatf("Pre-loading memory from file: %s\n", file), UVM_LOW);
        // read elf file (DPI call)
        void'(read_elf(file));

        // get the objdump verilog file to load our memorys
        $readmemh({file, ".hex"}, rmem);
        // copy double-wordwise from verilog file
        for (int i = 0; i < 16384; i++) begin
            dut.sp_ram_i.mem[i] = rmem[i];
        end

    endtask : preload_memories

    program testbench ();

        initial begin
            preload_memories();
        end

    endprogram

    testbench tb();

endmodule
