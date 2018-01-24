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
// Date: 29.05.2017
// Description: store_queue_if Monitor, monitors the DUT's pins and writes out
//              appropriate sequence items as defined for this particular dut

class store_queue_if_monitor extends uvm_component;

    // UVM Factory Registration Macro
    `uvm_component_utils(store_queue_if_monitor)

    // analysis port
    uvm_analysis_port #(store_queue_if_seq_item) m_ap;

    // Virtual Interface
    virtual store_queue_if m_vif;

    //---------------------
    // Data Members
    //---------------------
    store_queue_if_agent_config m_cfg;

    // Standard UVM Methods:
    function new(string name = "store_queue_if_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(store_queue_if_agent_config)::get(this, "", "store_queue_if_agent_config", m_cfg) )
        `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration store_queue_if_agent_config from uvm_config_db. Have you set() it?")

        m_ap = new("m_ap", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        // connect virtual interface
        m_vif = m_cfg.m_vif;
    endfunction

    task run_phase(uvm_phase phase);

        store_queue_if_seq_item cmd =  store_queue_if_seq_item::type_id::create("cmd");

        forever begin
            store_queue_if_seq_item cloned_item;
            // a new store item request has arrived
            @(m_vif.pck iff (m_vif.pck.store_valid && m_vif.pck.ready));
            // $display("%t, %0h", $time(), m_vif.pck.store_paddr);
            cmd.address = m_vif.pck.store_paddr[55:0];
            cmd.data    = m_vif.pck.store_data;
            cmd.be      = m_vif.pck.store_be;

            $cast(cloned_item, cmd.clone());
            m_ap.write(cloned_item);
        end

    endtask : run_phase
endclass : store_queue_if_monitor
