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
// Date: 02.05.2017
// Description: Environment which instantiates the agent and all environment
//              related components such as a scoreboard etc.

class lsu_env extends uvm_env;

    // UVM Factory Registration Macro
    `uvm_component_utils(lsu_env)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    mem_if_agent m_mem_if_agent;
    lsu_if_agent m_lsu_if_agent;

    lsu_if_sequencer m_lsu_if_sequencer;
    lsu_env_config m_cfg;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "lsu_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(lsu_env_config)::get(this, "", "lsu_env_config", m_cfg))
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration lsu_env_config from uvm_config_db. Have you set() it?")
        // Conditional instantiation goes here

        // Create mem_if agent configuration
        uvm_config_db #(mem_if_agent_config)::set(this, "m_mem_if_agent*",
                                               "mem_if_agent_config",
                                               m_cfg.m_mem_if_agent_config);
        m_mem_if_agent = mem_if_agent::type_id::create("m_mem_if_agent", this);
        // Create lsu_if agent configuration
        uvm_config_db #(lsu_if_agent_config)::set(this, "m_lsu_if_agent*",
                                               "lsu_if_agent_config",
                                               m_cfg.m_lsu_if_agent_config);
        m_lsu_if_agent = lsu_if_agent::type_id::create("m_lsu_if_agent", this);

        // Get sequencer
        m_lsu_if_sequencer = lsu_if_sequencer::type_id::create("m_lsu_if_sequencer", this);

    endfunction:build_phase

    function void connect_phase(uvm_phase phase);
       m_lsu_if_sequencer = m_lsu_if_agent.m_sequencer;
    endfunction: connect_phase
endclass : lsu_env
