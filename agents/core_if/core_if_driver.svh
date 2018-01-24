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
// Date: 08.05.2017
// Description: Driver for interface core_if

class core_if_driver extends uvm_driver #(core_if_seq_item);

    // UVM Factory Registration Macro
    `uvm_component_utils(core_if_driver)

    // Virtual Interface
    virtual core_if m_vif;

    //---------------------
    // Data Members
    //---------------------
    core_if_agent_config m_cfg;

    // Standard UVM Methods:
    function new(string name = "core_if_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        // core_if_seq_item cmd;
        // seq_item_port.get_next_item(cmd);

        // seq_item_port.item_done();
        m_vif.mck.test_en      <= 1'b0;
        m_vif.mck.clock_en     <= 1'b1;
        m_vif.mck.boot_addr    <= 64'h1000;
        m_vif.mck.core_id      <= 4'b0;
        m_vif.mck.cluster_id   <= 6'b0;
        m_vif.mck.irq          <= 1'b0;
        m_vif.mck.irq_id       <= 5'b0;
        m_vif.mck.irq_sec      <= 1'b0;
        m_vif.mck.fetch_enable <= 1'b0;

        repeat (20) @(m_vif.mck);
        m_vif.mck.fetch_enable <= 1'b1;

    endtask : run_phase

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(core_if_agent_config)::get(this, "", "core_if_agent_config", m_cfg) )
           `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration core_if_agent_config from uvm_config_db. Have you set() it?")

        m_vif = m_cfg.m_vif;
    endfunction: build_phase
endclass : core_if_driver
