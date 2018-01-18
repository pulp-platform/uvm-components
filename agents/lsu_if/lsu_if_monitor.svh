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
// Description: lsu_if Monitor, monitors the DUT's pins and writes out
//              appropriate sequence items as defined for this particular dut

class lsu_if_monitor extends uvm_component;

    // UVM Factory Registration Macro
    `uvm_component_utils(lsu_if_monitor)

    // analysis port
    uvm_analysis_port #(lsu_if_seq_item) m_ap;

    // Virtual Interface
    virtual lsu_if m_vif;

    //---------------------
    // Data Members
    //---------------------
    lsu_if_agent_config m_cfg;

    // Standard UVM Methods:
    function new(string name = "lsu_if_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(lsu_if_agent_config)::get(this, "", "lsu_if_agent_config", m_cfg) )
         `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration lsu_if_agent_config from uvm_config_db. Have you set() it?")

        m_ap = new("m_ap", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        // connect virtual interface
        m_vif = m_cfg.m_vif;
    endfunction

    task run_phase(uvm_phase phase);

    	lsu_if_seq_item cmd =  lsu_if_seq_item::type_id::create("cmd");
    	lsu_if_seq_item cloned_item;


        $cast(cloned_item, cmd.clone());
        m_ap.write(cloned_item);

    endtask : run_phase
endclass : lsu_if_monitor
