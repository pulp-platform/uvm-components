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

module kerbin_tb;
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

    dcache_if dcache_if (clk_i);

    localparam BAUDRATE = 115200; // 1562500
    localparam TCP_PORT = 4567;
    localparam CLK_SEL = 1'b1;

    // ------------------
    // UART
    // ------------------
    logic uart_tx;
    logic uart_rx;
    // use 8N1
    uart_bus #(
      .BAUD_RATE  ( BAUDRATE ),
      .PARITY_EN  ( 0        )
    ) i_uart (
      .rx         ( uart_rx  ),
      .tx         ( uart_tx  ),
      .rx_en      ( 1'b1     )
    );

    // ------------------
    // JTAG DPI
    // ------------------
    logic tms;
    logic tck;
    logic trst;
    logic tdi;
    logic tdo;
    logic jtag_enable;

    jtag_dpi #(
        .TCP_PORT ( TCP_PORT       )
    ) i_jtag_dpi (
        .clk_i    ( clk_i          ),
        .enable_i ( jtag_enable    ),
        .tms_o    ( tms            ),
        .tck_o    ( tck            ),
        .trst_o   ( trst           ),
        .tdi_o    ( tdi            ),
        .tdo_i    ( tdo            )
    );

    // ------------------
    // DUT (Kerbin)
    // ------------------
    kerbin dut (
        .clk_i             ( rtc_i          ),
        .clk_sel_i         ( CLK_SEL        ),
        .rst_ni            ( rst_ni         ),
        .test_en_i         ( 1'b0           ),
        .tck_i             ( tck            ),
        .tms_i             ( tms            ),
        .trstn_i           ( trst           ),
        .tdi_i             ( tdi            ),
        .tdo_o             ( tdo            ),
        .rts_o             (                ),
        .cts_i             (                ),
        .rx_i              ( uart_tx        ),
        .tx_o              ( uart_rx        ),
        .spi_clk           (                ),
        .spi_csn0          (                ),
        .spi_csn1          (                ),
        .spi_csn2          (                ),
        .spi_csn3          (                ),
        .spi_mode          (                ),
        .spi_sdo0          (                ),
        .spi_sdo1          (                ),
        .spi_sdo2          (                ),
        .spi_sdo3          (                ),
        .spi_sdi0          (                ),
        .spi_sdi1          (                ),
        .spi_sdi2          (                ),
        .spi_sdi3          (                ),
        .hyper_clk_o       (                ),
        .hyper_clk_no      (                ),
        .hyper_cs0_no      (                ),
        .hyper_cs1_no      (                ),
        .hyper_rwds_o      (                ),
        .hyper_rwds_oe_no  (                ),
        .hyper_rwds_i      (                ),
        .hyper_dq_oe_no    (                ),
        .hyper_dq_o        (                ),
        .hyper_dq_i        (                ),
        .gpio_o            (                ),
        .gpio_i            (                ),
        .gpio_oe_o         (                ),
        .pad_cfg_o         (                )
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

    initial begin
        jtag_enable = 1'b0;

        #1000 jtag_enable = 1'b1;
    end
    // ------------------
    // Fetch Enable
    // ------------------
    initial begin

    end

     function automatic logic [257:0] get_memory_word(logic [255:0] in);
        automatic logic [257:0] out = 'x;

        for (int i = 0; i < 32; i++) begin
            out[4*i+:4] = {in[i+192 +: 1], in[i+128 +: 1], in[i+64 +: 1], in[i +: 1]};
        end

        for (int i = 32; i < 64; i++) begin
            out[4*i+1+:4] = {in[i+192 +: 1], in[i+128 +: 1], in[i+64 +: 1], in[i +: 1]};
        end

        return out;
    endfunction : get_memory_word

    task preload_memories();
        string plus_args [$];

        string file;
        string file_name;
        string base_dir;
        string test;
        // offset the temporary RAM
        logic [63:0] rmem [2**16];

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
        for (int i = 0; i < 2**16; i+=4) begin
            if (!i[18]) begin
                for (int j = 0; j < 4; j++) begin
                    automatic int unsigned i0 = 4*i+0+j;
                    automatic int unsigned i1 = 4*i+4+j;
                    automatic int unsigned i2 = 4*i+8+j;
                    automatic int unsigned i3 = 4*i+12+j;
                    dut.l2_mem.genblk2[0].cut.mem0.array[i+j] = get_memory_word({rmem[i3], rmem[i2], rmem[i1], rmem[i0]});
                end
            end else
                for (int j = 0; j < 4; j++) begin
                    automatic int unsigned i0 = 4*i+0+j;
                    automatic int unsigned i1 = 4*i+4+j;
                    automatic int unsigned i2 = 4*i+8+j;
                    automatic int unsigned i3 = 4*i+12+j;
                    dut.l2_mem.genblk2[1].cut.mem0.array[i+j] = get_memory_word({rmem[i3], rmem[i2], rmem[i1], rmem[i0]});
                end
        end

    endtask : preload_memories

    program testbench (dcache_if dcache_if);
        longint unsigned begin_signature_address;
        longint unsigned tohost_address;
        string max_cycle_string;

        initial begin
            preload_memories();

            uvm_config_db #(virtual dcache_if )::set(null, "uvm_test_top", "dcache_if", dcache_if);
            // we are interested in the .tohost ELF symbol in-order to observe end of test signals
            tohost_address = get_symbol_address("tohost");
            begin_signature_address = get_symbol_address("begin_signature");
            uvm_report_info("Program Loader", $sformatf("tohost: %h begin_signature %h\n", tohost_address, begin_signature_address), UVM_LOW);

            // Start UVM test
            // run_test();
        end
    endprogram

    testbench tb(dcache_if);

endmodule
