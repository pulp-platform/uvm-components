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
// Date: 04.07.2017
// Description: Top Level Testbench

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
