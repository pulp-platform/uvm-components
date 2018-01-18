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
// Description: Driver for interface lsu_if

class lsu_if_driver extends uvm_driver #(lsu_if_seq_item);

    // UVM Factory Registration Macro
    `uvm_component_utils(lsu_if_driver)

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

    task run_phase(uvm_phase phase);
        semaphore lock = new(1);

        lsu_if_seq_item cmd;
        // reset values
        m_vif.mck.lsu_trans_id_id <= 'b0;
        m_vif.mck.source_valid    <= 1'b0;
        m_vif.mck.imm             <= 'b0;
        m_vif.mck.operator        <=  ADD;
        m_vif.mck.operand_a       <= 'b0;
        m_vif.mck.operand_b       <= 'b0;
        m_vif.mck.commit          <= 1'b0;
        forever begin
            // if the LSU is ready apply a new stimuli
            @(m_vif.mck);
            if (m_vif.mck.ready) begin
                seq_item_port.get_next_item(cmd);
                // we potentially want to wait a couple of cycles before applying
                // a new request
                repeat(cmd.requestDelay) @(m_vif.mck);
                // the data we apply is valid
                m_vif.mck.lsu_trans_id_id <= cmd.trans_id;
                m_vif.mck.source_valid    <= 1'b1;
                m_vif.mck.imm             <= cmd.imm;
                m_vif.mck.operator        <= cmd.operator;
                m_vif.mck.operand_a       <= cmd.operandA;
                m_vif.mck.operand_b       <= cmd.operandB;
                @(m_vif.mck);
                // spawn a commit thread that will eventually commit this instruction
                case (cmd.operator)
                    SD, SW, SH, SB:
                        fork
                            commit_thread: begin
                                lock.get(1);
                                    @(m_vif.mck);
                                    m_vif.mck.commit <= 1'b1;
                                    @(m_vif.mck);
                                    m_vif.mck.commit <= 1'b0;
                                lock.put(1);
                            end
                        join_none
                endcase
                m_vif.mck.source_valid    <= 1'b0;
                seq_item_port.item_done();
            end else
                m_vif.mck.source_valid <= 1'b0;

        end
    endtask : run_phase

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(lsu_if_agent_config)::get(this, "", "lsu_if_agent_config", m_cfg) )
           `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration lsu_if_agent_config from uvm_config_db. Have you set() it?")

        m_vif = m_cfg.m_vif;
    endfunction: build_phase
endclass : lsu_if_driver
