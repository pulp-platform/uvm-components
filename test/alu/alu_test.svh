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
// Date: 12/20/2016
// Description: This is the main implementation of the test class.
//              Randomized testing should take place here.

class alu_test extends alu_test_base;
    // UVM Factory Registration Macro
    `uvm_component_utils(alu_test)

    fibonacci_sequence fibonacci;
    add_sequence  add_sequence;
    addw_sequence addw_sequence;
    subw_sequence subw_sequence;
    sub_sequence  sub_sequence;
    xor_sequence  xor_sequence;
    or_sequence   or_sequence;
    and_sequence  and_sequence;
    sra_sequence  sra_sequence;
    srl_sequence  srl_sequence;
    sll_sequence  sll_sequence;
    sraw_sequence sraw_sequence;
    srlw_sequence srlw_sequence;
    sllw_sequence sllw_sequence;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "alu_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "alu_test");
        //fibonacci_sequence fibonacci;
        super.run_phase(phase);

        add_sequence = new("add");
        add_sequence.start(sequencer_h);

        addw_sequence = new("addw");
        addw_sequence.start(sequencer_h);

        subw_sequence = new("subw");
        subw_sequence.start(sequencer_h);

        sub_sequence = new("sub");
        sub_sequence.start(sequencer_h);

        xor_sequence = new("xor");
        xor_sequence.start(sequencer_h);

        or_sequence  = new("or");
        or_sequence.start(sequencer_h);

        and_sequence = new("and");
        and_sequence.start(sequencer_h);

        sra_sequence = new("sra");
        sra_sequence.start(sequencer_h);

        srl_sequence = new("srl");
        srl_sequence.start(sequencer_h);

        sll_sequence = new("sll");
        sll_sequence.start(sequencer_h);

        sraw_sequence = new("sraw");
        sraw_sequence.start(sequencer_h);

        srlw_sequence = new("srlw");
        srlw_sequence.start(sequencer_h);

        sllw_sequence = new("sllw");
        sllw_sequence.start(sequencer_h);

        fibonacci = new("fibonacci");
        fibonacci.start(sequencer_h);
        // Testlogic goes here
        #100ns;

        phase.drop_objection(this, "alu_test");
    endtask


endclass : alu_test
