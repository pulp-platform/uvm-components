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
// Date: 30.04.2017
// Description: Environment which instantiates the agent and all environment
//              related components such as a scoreboard etc.

class mem_arbiter_env extends uvm_env;

    // UVM Factory Registration Macro
    `uvm_component_utils(mem_arbiter_env)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    dcache_if_agent m_dcache_if_slave_agent;
    dcache_if_agent m_dcache_if_master_agents[3];

    dcache_if_sequencer m_dcache_if_sequencers[3];
    mem_arbiter_env_config m_cfg;

    mem_arbiter_scoreboard m_scoreboard;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "mem_arbiter_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(mem_arbiter_env_config)::get(this, "", "mem_arbiter_env_config", m_cfg))
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration mem_arbiter_env_config from uvm_config_db. Have you set() it?")
        // Conditional instantiation goes here

        // Create agent configurations
        uvm_config_db #(dcache_if_agent_config)::set(this, "m_dcache_if_slave*",
                                               "dcache_if_agent_config",
                                               m_cfg.m_dcache_if_slave_agent);


        m_dcache_if_slave_agent = dcache_if_agent::type_id::create("m_dcache_if_slave_agent", this);

        // create 3 master memory interfaces
        for (int i = 0; i < 3; i++) begin
            uvm_config_db #(dcache_if_agent_config)::set(this, {"m_dcache_if_master", i, "*"},
                                       "dcache_if_agent_config",
                                       m_cfg.m_dcache_if_master_agents[i]);

            m_dcache_if_master_agents[i] = dcache_if_agent::type_id::create({"m_dcache_if_master", i, "_agent"}, this);
            // Get 3 sequencers
            m_dcache_if_sequencers[i] = dcache_if_sequencer::type_id::create({"m_dcache_if_sequencer", i}, this);
        end
        // instantiate the scoreboard
        m_scoreboard = mem_arbiter_scoreboard::type_id::create("m_scoreboard", this);
    endfunction:build_phase

    function void connect_phase(uvm_phase phase);
        // connect the sequencers and monitor to the master agents
        for (int i = 0; i < 3; i++) begin
            m_dcache_if_sequencers[i] = m_dcache_if_master_agents[i].m_sequencer;
            m_dcache_if_master_agents[i].m_monitor.m_ap.connect(m_scoreboard.item_export);
        end
        // connect the slave monitor to the scoreboard
        m_dcache_if_slave_agent.m_monitor.m_ap.connect(m_scoreboard.item_export);
    endfunction: connect_phase
endclass : mem_arbiter_env
