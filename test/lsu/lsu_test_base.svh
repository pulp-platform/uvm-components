// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 02.05.2017
// Description: lsu base test class

class lsu_test_base extends uvm_test;

    // UVM Factory Registration Macro
    `uvm_component_utils(lsu_test_base)

    //------------------------------------------
    // Data Members
    //------------------------------------------

    //------------------------------------------
    // Component Members
    //------------------------------------------
    // environment configuration
    lsu_env_config m_env_cfg;
    // environment
    lsu_env m_env;
    lsu_if_sequencer sequencer_h;

    // ---------------------
    // Agent configuration
    // ---------------------
    // functional unit interface
    mem_if_agent_config m_mem_if_cfg;
    lsu_if_agent_config m_lsu_if_cfg;

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    function new(string name = "lsu_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build the environment, get all configurations
    // Use the factory pattern in order to facilitate UVM functionality
    function void build_phase(uvm_phase phase);
        // create environment
        m_env_cfg = lsu_env_config::type_id::create("m_env_cfg");

        // create agent configurations and assign interfaces
        m_mem_if_cfg = mem_if_agent_config::type_id::create("m_mem_if_cfg");
        m_env_cfg.m_mem_if_agent_config = m_mem_if_cfg;
        // make it a slave agent
        m_env_cfg.m_mem_if_agent_config.mem_if_config = SLAVE_REPLAY;
        // create lsu agent configuration
        m_lsu_if_cfg = lsu_if_agent_config::type_id::create("m_lsu_if_cfg");
        m_env_cfg.m_lsu_if_agent_config = m_lsu_if_cfg;
        // Get Virtual Interfaces
        // get memory interface DB
        if (!uvm_config_db #(virtual mem_if)::get(this, "", "mem_if", m_mem_if_cfg.fu))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface mem_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_mem_if = m_mem_if_cfg.fu;
        // get lsu interface
        if (!uvm_config_db #(virtual lsu_if)::get(this, "", "lsu_if", m_lsu_if_cfg.m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface lsu_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_lsu_if = m_lsu_if_cfg.m_vif;

        // create environment
        uvm_config_db #(lsu_env_config)::set(this, "*", "lsu_env_config", m_env_cfg);
        m_env = lsu_env::type_id::create("m_env", this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        sequencer_h = m_env.m_lsu_if_sequencer;
    endfunction

    task run_phase(uvm_phase phase);
        // reset = new("reset");
        // reset.start(sequencer_h);
    endtask

endclass : lsu_test_base
