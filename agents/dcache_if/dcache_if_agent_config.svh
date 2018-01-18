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
// Date: 29.05.2017
// Description: Agent configuration object dcache_if

class dcache_if_agent_config extends uvm_object;

    // UVM Factory Registration Macro
    `uvm_object_utils(dcache_if_agent_config)

    // Virtual Interface
    virtual dcache_if m_vif;
    // Is this a master or a slave interface
    dcache_if_config_t dcache_if_config;
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Is the agent active or passive
    uvm_active_passive_enum active = UVM_ACTIVE;

    // Standard UVM Methods:
    function new(string name = "dcache_if_agent_config");
        super.new(name);
    endfunction : new

endclass : dcache_if_agent_config



