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
// Date: 12/21/2016
// Description: Instruction cache main verification environment

class alu_env extends uvm_env;

    // UVM Factory Registration Macro
    `uvm_component_utils(alu_env)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    fu_if_agent m_fu_if_agent;
    fu_if_sequencer m_fu_if_sequencer;
    alu_env_config m_cfg;
    alu_scoreboard m_scoreboard;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "alu_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(alu_env_config)::get(this, "", "alu_env_config", m_cfg))
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration alu_env_config from uvm_config_db. Have you set() it?")
        // Conditional instantiation goes here

        // Create agent configuration
        uvm_config_db #(fu_if_agent_config)::set(this, "m_fu_if_agent*",
                                               "fu_if_agent_config",
                                               m_cfg.m_fu_if_agent_config);
        m_fu_if_agent = fu_if_agent::type_id::create("m_fu_if_agent", this);

        // Get sequencer
        m_fu_if_sequencer = fu_if_sequencer::type_id::create("m_fu_if_sequencer", this);

       // create scoreboard
       m_scoreboard = alu_scoreboard::type_id::create("m_scoreboard", this);

    endfunction:build_phase

    function void connect_phase(uvm_phase phase);
       m_fu_if_sequencer = m_fu_if_agent.m_sequencer;
       m_fu_if_agent.m_monitor.ap.connect(m_scoreboard.item_export);
    endfunction: connect_phase
endclass : alu_env
