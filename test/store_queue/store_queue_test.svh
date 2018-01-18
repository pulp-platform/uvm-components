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
// Description: store_queue main test class

class store_queue_test extends store_queue_test_base;
    // UVM Factory Registration Macro
    `uvm_component_utils(store_queue_test)
    store_queue_sequence store_queue;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "store_queue_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        uvm_objection objection;

        phase.raise_objection(this, "store_queue_test");
        #200ns;
        super.run_phase(phase);

        store_queue = new("store_queue");
        // Start sequence here
        store_queue.start(sequencer_h);

        objection = phase.get_objection();
        objection.set_drain_time(this, 100ns );

        phase.drop_objection(this, "store_queue_test");
    endtask


endclass : store_queue_test
