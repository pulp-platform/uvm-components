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
// Date: 12/20/2016
// Description: Configuration file for the pure instruction cache environment

class alu_env_config extends uvm_object;

    // UVM Factory Registration Macro
    `uvm_object_utils(alu_env_config)

    // a functional unit master interface
    virtual fu_if m_fu_if;

    // an agent config

    fu_if_agent_config m_fu_if_agent_config;

endclass : alu_env_config
