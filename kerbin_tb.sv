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
import uvm_pkg::*;
import core_lib_pkg::*;
import core_env_pkg::core_test_util;

`timescale 1ns / 1ps

`define DRAM_BASE 64'h40000000
`define DRV_SIG   .NDIN(1'b0), .NDOUT(), .DRV(2'b10), .PWROK(PWROK_S), .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)

`define SPI_STD     2'b00
`define SPI_QUAD_TX 2'b01
`define SPI_QUAD_RX 2'b10
`define SPI_IDLE    2'b11

`include "uvm_macros.svh"

module kerbin_tb;
    import "DPI-C" function chandle read_elf(string fn);
    import "DPI-C" function longint unsigned get_section_address(string symb);
    import "DPI-C" function longint unsigned get_section_size(string symb);
    import "DPI-C" function longint unsigned get_symbol_address(string symb);

    static uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();

    localparam int unsigned CLOCK_PERIOD = 20ns;
    localparam int unsigned RTC_PERIOD = (30.517578us/2);

    parameter  ENABLE_DEBUG_BRIDGE = 0;

    logic clk_i;
    logic rst_ni;
    logic rtc_i;

    logic clock_en_i;
    logic test_en_i;

    core_if   core_if (dut.uncore_i.coreplex_i.ariane_i.clk_i);
    dcache_if ptw (dut.uncore_i.coreplex_i.ariane_i.clk_i);
    dcache_if load_unit (dut.uncore_i.coreplex_i.ariane_i.clk_i);
    mem_if    store_unit (dut.uncore_i.coreplex_i.ariane_i.clk_i);

    longint unsigned max_cycles;

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
    logic fetch_enable;

    jtag_sim_bus jtag_sim();

    // mux JTAG -> this one activates the JTAG DPI
    if (ENABLE_DEBUG_BRIDGE) begin

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

    end else begin

        assign tck  = jtag_sim.tck;
        assign trst = jtag_sim.trstn;
        assign tdi  = jtag_sim.tdi;
        assign tms  = jtag_sim.tms;
        assign jtag_sim.tdo = tdo;

        initial begin
            fetch_enable = 1'b0;
            // enable fetch enable for now
            @(posedge jtag_enable)
            pkg_jtag_adbg::init(jtag_sim, 2, 1);
            pkg_jtag_pulp::init(jtag_sim, 2, 0);
            jtag_sim.set_ir(8'b01001111, 8);
            pkg_jtag_pulp::config_set(jtag_sim, 32'h8000_0001);
            fetch_enable = 1'b1;
        end
    end

    logic         spi_clk;
    logic [1:0]   spi_mode;
    logic         spi_sdo0;
    logic         spi_sdo1;
    logic         spi_sdo2;
    logic         spi_sdo3;
    logic         spi_sdi0;
    logic         spi_sdi1;
    logic         spi_sdi2;
    logic         spi_sdi3;
    logic         use_qspi;
    logic         spi_csn0;

    wire          pad_csn0;
    wire          pad_spi0;
    wire          pad_spi1;
    wire          pad_spi2;
    wire          pad_spi3;
    wire          pad_sclk;

    logic         hyper_clk;
    logic         hyper_clk_n;
    logic         hyper_cs0_n;
    logic         hyper_cs1_n;
    logic         hyper_rwds_o;
    logic         hyper_rwds_oe_n;
    logic         hyper_rwds_i;
    logic         hyper_dq_oe_n;
    logic [7:0]   hyper_dq_o;
    logic [7:0]   hyper_dq_i;
    logic         hyper_reset_n;

    wire  [7:0]   pad_dq;
    wire          pad_rwds;
    wire          pad_cs0_n;
    wire          pad_clk;
    wire          pad_clk_n;
    wire          pad_reset;
    // ------------------
    // DUT (Kerbin)
    // ------------------
    kerbin dut (
        .clk_i             ( clk_i                  ),
        .rst_ni            ( rst_ni                 ),
        .test_en_i         ( 1'b0                   ),
        .fetch_enable_i    ( fetch_enable           ),
        .tck_i             ( tck                    ),
        .tms_i             ( tms                    ),
        .trstn_i           ( trst                   ),
        .tdi_i             ( tdi                    ),
        .tdo_o             ( tdo                    ),
        .rts_o             (                        ),
        .cts_i             (                        ),
        .rx_i              ( uart_tx                ),
        .tx_o              ( uart_rx                )
    );

    // ------------------
    // Connect Checker
    // ------------------
    // connect core store interface
    assign store_unit.address       = {dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.address_tag_o, dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.address_index_o};
    assign store_unit.data_wdata    = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_wdata_o;
    assign store_unit.data_req      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_req_o;
    assign store_unit.data_we       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_we_o;
    assign store_unit.data_be       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_be_o;
    assign store_unit.data_gnt      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_gnt_i;
    assign store_unit.data_rvalid   = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_store_unit.data_rvalid_i;
    assign store_unit.data_rdata    = '0;

    // connect load interface
    assign load_unit.address_index = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.address_index_o;
    assign load_unit.address_tag   = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.address_tag_o;
    assign load_unit.data_wdata    = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_wdata_o;
    assign load_unit.data_we       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_we_o;
    assign load_unit.data_req      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_req_o;
    assign load_unit.tag_valid     = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.tag_valid_o;
    assign load_unit.data_be       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_be_o;
    assign load_unit.kill_req      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.kill_req_o;
    assign load_unit.data_rvalid   = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_rvalid_i;
    assign load_unit.data_rdata    = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_rdata_i;
    assign load_unit.data_gnt      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_load_unit.data_gnt_i;

    // connect ptw interface
    assign ptw.address_index = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.address_index_o;
    assign ptw.address_tag   = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.address_tag_o;
    assign ptw.data_wdata    = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_wdata_o;
    assign ptw.data_we       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_we_o;
    assign ptw.data_req      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_req_o;
    assign ptw.tag_valid     = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.tag_valid_o;
    assign ptw.data_be       = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_be_o;
    assign ptw.kill_req      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.kill_req_o;
    assign ptw.data_rvalid   = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_rvalid_i;
    assign ptw.data_rdata    = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_rdata_i;
    assign ptw.data_gnt      = dut.uncore_i.coreplex_i.ariane_i.ex_stage_i.lsu_i.i_mmu.ptw_i.data_gnt_i;

    // ------------------
    // Clocking Process
    // ------------------
    initial begin
            // 150000000000 fs
        rst_ni = 1'b0;
        #300000 rst_ni = 1'b1;
    end

    initial begin
        clk_i = 1'b0;

        repeat(8)
            #(CLOCK_PERIOD/2) clk_i = ~clk_i;

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

    // -----------------
    // Test Bench
    // -----------------
    program testbench (core_if core_if, dcache_if load_unit, dcache_if ptw, mem_if mem_if);
        longint unsigned begin_signature_address;
        longint unsigned tohost_address;
        string max_cycle_string;
        string file;
        core_test_util ctu;

        initial begin

            ctu = core_test_util::type_id::create("core_test_util");
            file = ctu.get_file_name();
            void'(ctu.preload_memories(file));

            // read elf file (DPI call)
            void'(read_elf(file));

            for (int i = 0; i < 2**16; i+=4) begin
                if (!i[18]) begin
                    for (int j = 0; j < 4; j++) begin
                        automatic int unsigned i0 = 4*i+0+j;
                        automatic int unsigned i1 = 4*i+4+j;
                        automatic int unsigned i2 = 4*i+8+j;
                        automatic int unsigned i3 = 4*i+12+j;
                        dut.l2_mem.genblk1[0].cut.mem0.array[i+j] = get_memory_word({ctu.rmem[i3], ctu.rmem[i2], ctu.rmem[i1], ctu.rmem[i0]});
                    end
                end else
                    for (int j = 0; j < 4; j++) begin
                        automatic int unsigned i0 = 4*i+0+j;
                        automatic int unsigned i1 = 4*i+4+j;
                        automatic int unsigned i2 = 4*i+8+j;
                        automatic int unsigned i3 = 4*i+12+j;
                        dut.l2_mem.genblk1[1].cut.mem0.array[i+j] = get_memory_word({ctu.rmem[i3], ctu.rmem[i2], ctu.rmem[i1], ctu.rmem[i0]});
                    end
                end

            uvm_config_db #(virtual core_if)::set(null, "uvm_test_top", "core_if", core_if);
            uvm_config_db #(virtual dcache_if)::set(null, "uvm_test_top", "dcache_if", load_unit);
            uvm_config_db #(virtual dcache_if)::set(null, "uvm_test_top", "ptw_if", ptw);
            uvm_config_db #(virtual mem_if )::set(null, "uvm_test_top", "mem_if", mem_if);

            // we are interested in the .tohost ELF symbol in-order to observe end of test signals
            tohost_address = get_symbol_address("tohost");
            begin_signature_address = get_symbol_address("begin_signature");
            uvm_report_info("Program Loader", $sformatf("tohost: %h begin_signature %h\n", tohost_address, begin_signature_address), UVM_LOW);
            // pass tohost address to UVM resource DB
            uvm_config_db #(longint unsigned)::set(null, "uvm_test_top.m_env.m_eoc", "tohost", tohost_address);
            uvm_config_db #(longint unsigned)::set(null, "uvm_test_top.m_env.m_dcache_scoreboard", "dram_base", `DRAM_BASE);
            uvm_config_db #(longint unsigned)::set(null, "uvm_test_top.m_env.m_dcache_scoreboard", "begin_signature", ((begin_signature_address -`DRAM_BASE) >> 3));
            uvm_config_db #(core_test_util)::set(null, "uvm_test_top.m_env.m_dcache_scoreboard", "memory_file", ctu);
            // print the topology
            // uvm_top.enable_print_topology = 1;
            // get the maximum cycle count the simulation is allowed to run
            if (uvcl.get_arg_value("+max-cycles=", max_cycle_string) == 0) begin
                max_cycles = {64{1'b1}};
            end else begin
                max_cycles = max_cycle_string.atoi();
            end
            // Start UVM test
            run_test();
        end
    endprogram

    testbench tb (core_if, load_unit, ptw, store_unit);
endmodule
