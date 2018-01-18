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
// Date: 12/21/2016
// Description: Driver of the memory interface

class scoreboard_if_driver extends uvm_driver #(scoreboard_if_seq_item);

    // UVM Factory Registration Macro
    `uvm_component_utils(scoreboard_if_driver)

    // Virtual Interface
    virtual scoreboard_if fu;

    //---------------------
    // Data Members
    //---------------------
    scoreboard_if_agent_config m_cfg;

    // Standard UVM Methods:
    function new(string name = "scoreboard_if_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        scoreboard_if_seq_item cmd;

    endtask : run_phase

    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(scoreboard_if_agent_config)::get(this, "", "scoreboard_if_agent_config", m_cfg) )
         `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration scoreboard_if_agent_config from uvm_config_db. Have you set() it?")

      fu = m_cfg.fu;
    endfunction: build_phase
endclass : scoreboard_if_driver
