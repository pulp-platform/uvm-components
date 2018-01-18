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
// Date: 30.04.2017
// Description: mem_arbiter base test class

class mem_arbiter_test_base extends uvm_test;

    // UVM Factory Registration Macro
    `uvm_component_utils(mem_arbiter_test_base)

    //------------------------------------------
    // Data Members
    //------------------------------------------

    //------------------------------------------
    // Component Members
    //------------------------------------------
    // environment configuration
    mem_arbiter_env_config m_env_cfg;
    // environment
    mem_arbiter_env m_env;
    dcache_if_sequencer sequencer_h[3];

    // reset_sequence reset;
    // ---------------------
    // Agent configuration
    // ---------------------
    // functional unit interface
    dcache_if_agent_config m_cfg_slave;
    dcache_if_agent_config m_cfg_masters[3];

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    function new(string name = "mem_arbiter_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build the environment, get all configurations
    // Use the factory pattern in order to facilitate UVM functionality
    function void build_phase(uvm_phase phase);
        // create environment
        m_env_cfg = mem_arbiter_env_config::type_id::create("m_env_cfg");
        // create agent configurations and assign interfaces
        // create a slave configuration
        m_cfg_slave = dcache_if_agent_config::type_id::create("m_cfg_slave");
        m_env_cfg.m_dcache_if_slave_agent = m_cfg_slave;
        m_env_cfg.m_dcache_if_slave_agent.dcache_if_config = SLAVE_REPLAY;

        // create agent memory master configuration
        m_cfg_masters[0] = dcache_if_agent_config::type_id::create("m_cfg_master0");
        m_env_cfg.m_dcache_if_master_agents[0] = m_cfg_masters[0];
        m_env_cfg.m_dcache_if_master_agents[0].dcache_if_config = MASTER;

        m_cfg_masters[1] = dcache_if_agent_config::type_id::create("m_cfg_master1");
        m_env_cfg.m_dcache_if_master_agents[1] = m_cfg_masters[1];
        m_env_cfg.m_dcache_if_master_agents[1].dcache_if_config = MASTER;

        m_cfg_masters[2] = dcache_if_agent_config::type_id::create("m_cfg_master2");
        m_env_cfg.m_dcache_if_master_agents[2] = m_cfg_masters[2];
        m_env_cfg.m_dcache_if_master_agents[2].dcache_if_config = MASTER;
        // Get Virtual Interfaces
        // get master interface DB
        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "dcache_if_slave", m_cfg_slave.m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface dcache_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_dcache_if_slave = m_cfg_slave.m_vif;

        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "dcache_if_master0", m_cfg_masters[0].m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface dcache_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_dcache_if_masters[0] = m_cfg_slave.m_vif;

        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "dcache_if_master1", m_cfg_masters[1].m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface dcache_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_dcache_if_masters[1] = m_cfg_slave.m_vif;

        if (!uvm_config_db #(virtual dcache_if)::get(this, "", "dcache_if_master2", m_cfg_masters[2].m_vif))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface dcache_if from uvm_config_db. Have you set() it?")
        m_env_cfg.m_dcache_if_masters[2] = m_cfg_slave.m_vif;

        // create environment
        uvm_config_db #(mem_arbiter_env_config)::set(this, "*", "mem_arbiter_env_config", m_env_cfg);
        m_env = mem_arbiter_env::type_id::create("m_env", this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        sequencer_h[0] = m_env.m_dcache_if_sequencers[0];
        sequencer_h[1] = m_env.m_dcache_if_sequencers[1];
        sequencer_h[2] = m_env.m_dcache_if_sequencers[2];
    endfunction

    task run_phase(uvm_phase phase);
        // reset = new("reset");
        // reset.start(sequencer_h);
    endtask

endclass : mem_arbiter_test_base
