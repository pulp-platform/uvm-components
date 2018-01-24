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
// Date: 29.05.2017
// Description: Environment which instantiates the agent and all environment
//              related components such as a scoreboard etc.

class store_queue_env extends uvm_env;

    // UVM Factory Registration Macro
    `uvm_component_utils(store_queue_env)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    // agents
    store_queue_if_agent m_store_queue_if_agent;
    mem_if_agent m_mem_if_agent;

    store_queue_if_sequencer m_store_queue_if_sequencer;
    store_queue_env_config m_cfg;

    store_queue_scoreboard m_scoreboard;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "store_queue_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(store_queue_env_config)::get(this, "", "store_queue_env_config", m_cfg))
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration store_queue_env_config from uvm_config_db. Have you set() it?")
        // Conditional instantiation goes here

        // Create agent configuration
        // Store Queue IF
        uvm_config_db #(store_queue_if_agent_config)::set(this, "m_store_queue_if_agent*",
                                               "store_queue_if_agent_config",
                                               m_cfg.m_store_queue_if_agent_config);
        m_store_queue_if_agent = store_queue_if_agent::type_id::create("m_store_queue_if_agent", this);

        // mem IF
        uvm_config_db #(mem_if_agent_config)::set(this, "m_mem_if_agent*",
                                               "mem_if_agent_config",
                                               m_cfg.m_mem_if_agent_config);
        m_mem_if_agent = mem_if_agent::type_id::create("m_mem_if_agent", this);

        // Get sequencer
        m_store_queue_if_sequencer = store_queue_if_sequencer::type_id::create("m_store_queue_if_sequencer", this);
        // instantiate scoreboard
        m_scoreboard = store_queue_scoreboard::type_id::create("m_scoreboard", this);
    endfunction:build_phase

    function void connect_phase(uvm_phase phase);
        m_store_queue_if_sequencer = m_store_queue_if_agent.m_sequencer;
        m_store_queue_if_agent.m_monitor.m_ap.connect(m_scoreboard.store_queue_item_export);
        m_mem_if_agent.m_monitor.m_ap.connect(m_scoreboard.mem_item_export);

    endfunction: connect_phase
endclass : store_queue_env
