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
// Description: mem_arbiter configuration object

class mem_arbiter_env_config extends uvm_object;

    // UVM Factory Registration Macro
    `uvm_object_utils(mem_arbiter_env_config)

    // a functional unit master interface
    virtual dcache_if m_dcache_if_slave;
    virtual dcache_if m_dcache_if_masters[3];
    // an agent config
    dcache_if_agent_config m_dcache_if_slave_agent;
    dcache_if_agent_config m_dcache_if_master_agents[3];

endclass : mem_arbiter_env_config
