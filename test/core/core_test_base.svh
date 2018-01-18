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
// Date: 08.05.2017
// Description: core base test class

class core_test_base extends uvm_test;

    // UVM Factory Registration Macro
    `uvm_component_utils(core_test_base)

    //------------------------------------------
    // Data Members
    //------------------------------------------

    //------------------------------------------
    // Component Members
    //------------------------------------------
    // environment configuration
    core_env_config m_env_cfg;
    // environment
    core_env m_env;
    core_if_sequencer sequencer_h;

    core_sequence m_core_sequence;
    // ---------------------
    // Agent configuration
    // ---------------------
    // functional unit interface
    core_if_agent_config m_core_if_cfg;
    dcache_if_agent_config  m_dcache_if_cfg;
    dcache_if_agent_config m_ptw_if_cfg;

    mem_if_agent_config m_mem_if_cfg;
    //------------------------------------------
    // Methods
    //------------------------------------------
    // standard UVM methods:
    function new(string name = "core_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // build the environment, get all configurations
    // use the factory pattern in order to facilitate UVM functionality
    function void build_phase(uvm_phase phase);
        // create environment
        m_env_cfg = core_env_config::type_id::create("m_env_cfg");

        // create agent configurations and assign interfaces
        // create agent core_if configuration
        m_core_if_cfg = core_if_agent_config::type_id::create("m_core_if_cfg");
        m_env_cfg.m_core_if_agent_config = m_core_if_cfg;

        m_dcache_if_cfg = dcache_if_agent_config::type_id::create("m_dcache_if_cfg");
        // configure the instruction interface as a slave device
        m_dcache_if_cfg.dcache_if_config = SLAVE_NO_RANDOM_DCACHE;
        m_dcache_if_cfg.active = UVM_PASSIVE;
        m_env_cfg.m_dcache_if_agent_config = m_dcache_if_cfg;

        m_mem_if_cfg = mem_if_agent_config::type_id::create("m_mem_if_cfg");
        m_mem_if_cfg.active = UVM_PASSIVE;
        m_mem_if_cfg.store_if = 1'b1;
        m_env_cfg.m_mem_if_agent_config = m_mem_if_cfg;

        m_ptw_if_cfg = dcache_if_agent_config::type_id::create("m_ptw_if_cfg");
        m_ptw_if_cfg.dcache_if_config = SLAVE_NO_RANDOM_DCACHE;
        m_ptw_if_cfg.active = UVM_PASSIVE;
        m_env_cfg.m_ptw_if_agent_config = m_ptw_if_cfg;

        // get core_if virtual interfaces
        // get master interface DB
        if (!uvm_config_db #(virtual core_if)::get(this, "", "core_if", m_core_if_cfg.m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface core_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_core_if = m_core_if_cfg.m_vif;

        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "dcache_if", m_dcache_if_cfg.m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface dcache_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_dcache_if = m_dcache_if_cfg.m_vif;

        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "ptw_if", m_ptw_if_cfg.m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface PTW interfaces from uvm_config_db. Have you set() it?")
        m_env_cfg.m_ptw_if = m_ptw_if_cfg.m_vif;

        if (!uvm_config_db #(virtual mem_if)::get(this, "", "mem_if", m_mem_if_cfg.fu))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface mem_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_mem_if = m_mem_if_cfg.fu;

        // create environment
        uvm_config_db #(core_env_config)::set(this, "*", "core_env_config", m_env_cfg);
        m_env = core_env::type_id::create("m_env", this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        sequencer_h = m_env.m_core_if_sequencer;
    endfunction

    task run_phase(uvm_phase phase);
        m_core_sequence = new("m_core_sequence");
        m_core_sequence.start(sequencer_h);
    endtask

endclass : core_test_base
