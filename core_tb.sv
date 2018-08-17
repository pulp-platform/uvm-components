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
// Date: 15/04/2017
// Description: Top level testbench module. Instantiates the top level DUT, configures
//              the virtual interfaces and starts the test passed by +UVM_TEST+


import ariane_pkg::*;
import uvm_pkg::*;
import core_lib_pkg::*;
import core_env_pkg::core_test_util;

`timescale 1ns / 1ps

`define DRAM_BASE 64'h40000000

`include "uvm_macros.svh"

module core_tb;
    import "DPI-C" function chandle read_elf(string fn);
    import "DPI-C" function longint unsigned get_section_address(string symb);
    import "DPI-C" function longint unsigned get_section_size(string symb);
    import "DPI-C" function longint unsigned get_symbol_address(string symb);

    static uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();

    localparam int unsigned CLOCK_PERIOD = 20ns;

    logic clk_i;
    logic rst_ni;
    logic [63:0] time_i;

    logic display_instr;

    longint unsigned cycles;
    longint unsigned max_cycles;

    debug_if debug_if();
    core_if core_if (clk_i);
    dcache_if ptw (clk_i);
    dcache_if load_unit (clk_i);
    mem_if store_unit (clk_i);

    logic [63:0] instr_if_address;
    logic        instr_if_data_req;
    logic        instr_if_data_gnt;
    logic        instr_if_data_rvalid;
    logic [63:0] instr_if_data_rdata;

    logic [63:0] data_if_data_address_i;
    logic [63:0] data_if_data_wdata_i;
    logic        data_if_data_req_i;
    logic        data_if_data_we_i;
    logic [7:0]  data_if_data_be_i;
    logic        data_if_data_gnt_o;
    logic        data_if_data_rvalid_o;
    logic [63:0] data_if_data_rdata_o;

    core_mem core_mem_i (
        .clk_i                   ( clk_i                        ),
        .rst_ni                  ( rst_ni                       ),

        .data_if_address_i       ( data_if_data_address_i       ),
        .data_if_data_wdata_i    ( data_if_data_wdata_i         ),
        .data_if_data_req_i      ( data_if_data_req_i           ),
        .data_if_data_we_i       ( data_if_data_we_i            ),
        .data_if_data_be_i       ( data_if_data_be_i            ),
        .data_if_data_rvalid_o   ( data_if_data_rvalid_o        ),
        .data_if_data_rdata_o    ( data_if_data_rdata_o         )
    );

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( 64 ),
        .AXI_DATA_WIDTH ( 64 ),
        .AXI_ID_WIDTH   ( 10 ),
        .AXI_USER_WIDTH ( 1  )
    ) data_if();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( 64 ),
        .AXI_DATA_WIDTH ( 64 ),
        .AXI_ID_WIDTH   ( 10 ),
        .AXI_USER_WIDTH ( 1  )
    ) bypass_if();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( 64 ),
        .AXI_DATA_WIDTH ( 64 ),
        .AXI_ID_WIDTH   ( 10 ),
        .AXI_USER_WIDTH ( 1  )
    ) instr_if();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( 64 ),
        .AXI_DATA_WIDTH ( 64 ),
        .AXI_ID_WIDTH   ( 12 ),
        .AXI_USER_WIDTH ( 1  )
    ) axi2per();

    axi2mem #(
        .AXI_ID_WIDTH   (12),
        .AXI_ADDR_WIDTH (64),
        .AXI_DATA_WIDTH (64),
        .AXI_USER_WIDTH (1)
    ) i_axi2mem (
        .slave   ( axi2per                ),
        .req_o   ( data_if_data_req_i     ),
        .we_o    ( data_if_data_we_i      ),
        .addr_o  ( data_if_data_address_i ),
        .be_o    ( data_if_data_be_i      ),
        .data_o  ( data_if_data_wdata_i   ),
        .data_i  ( data_if_data_rdata_o   ),
        .*
    );

    axi_node_intf_wrap #(
        .NB_MASTER      ( 1            ),
        .NB_SLAVE       ( 3            ),
        .AXI_ADDR_WIDTH ( 64           ),
        .AXI_DATA_WIDTH ( 64           ),
        .AXI_ID_WIDTH   ( 10           ),
        .AXI_USER_WIDTH ( 1            )
    ) i_axi_node (
        .clk            ( clk_i                           ),
        .rst_n          ( rst_ni                          ),
        .test_en_i      ( 1'b0                            ),
        .slave          ( '{bypass_if, data_if, instr_if} ),
        .master         ( '{axi2per}                      ),
        .start_addr_i   ( {64'h0}                         ),
        .end_addr_i     ( {64'hFFFF_FFFF_FFFF_FFFF}       )
    );

    ariane dut (
        .clk_i                   ( clk_i                        ),
        .rst_ni                  ( rst_ni                       ),
        .time_i                  ( time_i                       ),
        .time_irq_i              ( 1'b0                         ),
        .ipi_i                   ( 1'b0                         ),
        .test_en_i               ( core_if.test_en              ),
        .fetch_enable_i          ( core_if.fetch_enable         ),

        .boot_addr_i             ( core_if.boot_addr            ),
        .core_id_i               ( core_if.core_id              ),
        .cluster_id_i            ( core_if.cluster_id           ),
        .flush_dcache_ack_o      (                              ),
        .flush_dcache_i          ( 1'b0                         ),

        .instr_if                ( instr_if                     ),
        .data_if                 ( data_if                      ),
        .bypass_if               ( bypass_if                    ),

        .irq_i                   ( {core_if.irq, core_if.irq}   ),
        .sec_lvl_o               ( core_if.sec_lvl              ),

        .debug_req_i             (                              ),
        .debug_gnt_o             (                              ),
        .debug_rvalid_o          (                              ),
        .debug_addr_i            (                              ),
        .debug_we_i              (                              ),
        .debug_wdata_i           (                              ),
        .debug_rdata_o           (                              ),
        .debug_halted_o          (                              ),
        .debug_halt_i            (                              ),
        .debug_resume_i          (                              )
    );

    // connect core store interface
    assign store_unit.address       = {dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.address_tag, 
                                       dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.address_index};
    assign store_unit.data_wdata    = dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.data_wdata;
    assign store_unit.data_req      = dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.data_req;
    assign store_unit.data_we       = dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.data_we;
    assign store_unit.data_be       = dut.ex_stage_i.lsu_i.i_store_unit.req_port_o.data_be;
    assign store_unit.data_gnt      = dut.ex_stage_i.lsu_i.i_store_unit.req_port_i.data_gnt;
    assign store_unit.data_rvalid   = dut.ex_stage_i.lsu_i.i_store_unit.req_port_i.data_rvalid;
    assign store_unit.data_rdata    = '0;

    // connect load interface
    assign load_unit.address_index = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.address_index;
    assign load_unit.address_tag   = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.address_tag;
    assign load_unit.data_wdata    = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.data_wdata;
    assign load_unit.data_we       = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.data_we;
    assign load_unit.data_req      = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.data_req;
    assign load_unit.tag_valid     = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.tag_valid;
    assign load_unit.data_be       = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.data_be;
    assign load_unit.kill_req      = dut.ex_stage_i.lsu_i.i_load_unit.req_port_o.kill_req;

    assign load_unit.data_rvalid   = dut.ex_stage_i.lsu_i.i_load_unit.req_port_i.data_rvalid;
    assign load_unit.data_rdata    = dut.ex_stage_i.lsu_i.i_load_unit.req_port_i.data_rdata;
    assign load_unit.data_gnt      = dut.ex_stage_i.lsu_i.i_load_unit.req_port_i.data_gnt;
    // connect ptw interface
    assign ptw.address_index       = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.address_index;
    assign ptw.address_tag         = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.address_tag;
    assign ptw.data_wdata          = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.data_wdata;
    assign ptw.data_we             = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.data_we;
    assign ptw.data_req            = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.data_req;
    assign ptw.tag_valid           = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.tag_valid;
    assign ptw.data_be             = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.data_be;
    assign ptw.kill_req            = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o.kill_req;

    assign ptw.data_rvalid         = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_i.data_rvalid;
    assign ptw.data_rdata          = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_i.data_rdata;
    assign ptw.data_gnt            = dut.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_i.data_gnt;

    // Clock process
    initial begin
        clk_i = 1'b0;
        rst_ni = 1'b0;
        repeat(8)
            #(CLOCK_PERIOD/2) clk_i = ~clk_i;
        rst_ni = 1'b1;
        forever begin
            #(CLOCK_PERIOD/2) clk_i = 1'b1;
            #(CLOCK_PERIOD/2) clk_i = 1'b0;

            //if (cycles > max_cycles)
            //    $fatal(1, "Simulation reached maximum cycle count of %d", max_cycles);

            cycles++;
        end
    end
    // Real Time Clock
    initial begin
        // initialize platform timer
        time_i = 64'b0;
        // increment timer with a frequency of 32.768 kHz
        forever begin
            #30.517578us;
            time_i++;
        end
    end

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

            // copy double-wordwise from verilog file
            for (int i = 0; i < 2**21; i++)
                core_mem_i.ram_i.mem[i] = ctu.rmem[i];

            uvm_config_db #(virtual core_if)::set(null, "uvm_test_top", "core_if", core_if);
            uvm_config_db #(virtual dcache_if)::set(null, "uvm_test_top", "dcache_if", load_unit);
            uvm_config_db #(virtual dcache_if)::set(null, "uvm_test_top", "ptw_if", ptw);
            uvm_config_db #(virtual mem_if)::set(null, "uvm_test_top", "mem_if", mem_if);

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

    testbench tb(core_if, load_unit, ptw, store_unit);
endmodule
