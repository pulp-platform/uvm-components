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
// Description: Environment which instantiates the agent and all environment
//              related components such as a scoreboard etc.

class core_env #(int DATA_WIDTH = 64) extends uvm_env;

    // UVM Factory Registration Macro
    `uvm_component_param_utils(core_env#(DATA_WIDTH))

    //------------------------------------------
    // Data Members
    //------------------------------------------
    core_if_agent m_core_if_agent;
    dcache_if_agent m_dcache_if_agent;
    dcache_if_agent m_ptw_if_agent;
    mem_if_agent m_mem_if_agent;

    core_if_sequencer m_core_if_sequencer;
    core_env_config m_cfg;

    core_eoc m_eoc;
    dcache_scoreboard #(DATA_WIDTH) m_dcache_scoreboard;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "core_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(core_env_config)::get(this, "", "core_env_config", m_cfg))
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration core_env_config from uvm_config_db. Have you set() it?")
        // Conditional instantiation goes here

        // Create agent configuration
        uvm_config_db #(core_if_agent_config)::set(this, "m_core_if_agent*",
                                               "core_if_agent_config",
                                               m_cfg.m_core_if_agent_config);
        m_core_if_agent = core_if_agent::type_id::create("m_core_if_agent", this);

        uvm_config_db #(core_if_agent_config)::set(this, "m_core_if_agent*",
                                               "core_if_agent_config",
                                               m_cfg.m_core_if_agent_config);
        // get instruction memory interface
        m_dcache_if_agent = dcache_if_agent::type_id::create("m_dcache_if_agent", this);
        uvm_config_db #(dcache_if_agent_config)::set(this, "m_dcache_if_agent*",
                                               "dcache_if_agent_config",
                                               m_cfg.m_dcache_if_agent_config);

        // get instruction memory interface
        m_ptw_if_agent = dcache_if_agent::type_id::create("m_ptw_if_agent", this);
        uvm_config_db #(dcache_if_agent_config)::set(this, "m_ptw_if_agent*",
                                               "dcache_if_agent_config",
                                               m_cfg.m_ptw_if_agent_config);

        // get store memory interface
        m_mem_if_agent = mem_if_agent::type_id::create("m_mem_if_agent", this);
        uvm_config_db #(mem_if_agent_config)::set(this, "m_mem_if_agent*",
                                               "mem_if_agent_config",
                                               m_cfg.m_mem_if_agent_config);
        // Get sequencer
        m_core_if_sequencer = core_if_sequencer::type_id::create("m_core_if_sequencer", this);

        m_eoc  = core_eoc::type_id::create("m_eoc", this);
        m_dcache_scoreboard = dcache_scoreboard#(DATA_WIDTH)::type_id::create("m_dcache_scoreboard", this);
    endfunction:build_phase

    function void connect_phase(uvm_phase phase);
        m_core_if_sequencer = m_core_if_agent.m_sequencer;
        m_mem_if_agent.m_monitor.m_ap.connect(m_eoc.item_export);
        m_mem_if_agent.m_monitor.m_ap.connect(m_dcache_scoreboard.store_export);
        m_dcache_if_agent.m_monitor.m_ap.connect(m_dcache_scoreboard.load_export);
        m_ptw_if_agent.m_monitor.m_ap.connect(m_dcache_scoreboard.ptw_export);
    endfunction: connect_phase

endclass : core_env
