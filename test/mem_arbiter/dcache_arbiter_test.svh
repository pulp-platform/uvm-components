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
// Date: 30.04.2017
// Description: mem_arbiter main test class

class dcache_arbiter_test extends mem_arbiter_test_base;
    // UVM Factory Registration Macro
    `uvm_component_utils(dcache_arbiter_test)
    mem_arbiter_sequence mem_arbiter_sequences[3];
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "dcache_arbiter_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    // start the sequencer with number sequencer
    task start_sequence(int sequencer);
        mem_arbiter_sequences[sequencer] = new({"mem_arbiter_sequences", sequencer});
        mem_arbiter_sequences[sequencer].start(sequencer_h[sequencer]);
    endtask

    task run_phase(uvm_phase phase);
        uvm_objection objection;
        phase.raise_objection(this, "dcache_arbiter_test");
        #200ns;
        super.run_phase(phase);
        // fork three sequencers and wait for all of them to finish
        // until dropping the objection again
        fork
            start_sequence(0);
            start_sequence(1);
            start_sequence(2);
        join
        // Testlogic goes here
        // drain time until the objection gets dropped
        objection = phase.get_objection();
        objection.set_drain_time(this, 100ns );
        phase.drop_objection(this, "dcache_arbiter_test");
    endtask


endclass : dcache_arbiter_test
