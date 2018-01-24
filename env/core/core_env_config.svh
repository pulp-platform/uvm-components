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
// Description: core configuration object

class core_env_config extends uvm_object;

    // UVM Factory Registration Macro
    `uvm_object_utils(core_env_config)

    // a functional unit master interface
    virtual core_if m_core_if;
    // used for loads
    virtual dcache_if m_dcache_if;
    // used for ptw
    virtual dcache_if m_ptw_if;
    // used for stores
    virtual mem_if m_mem_if;

    // an agent config
    core_if_agent_config m_core_if_agent_config;
    dcache_if_agent_config m_dcache_if_agent_config;
    dcache_if_agent_config m_ptw_if_agent_config;
    mem_if_agent_config m_mem_if_agent_config;

endclass : core_env_config
