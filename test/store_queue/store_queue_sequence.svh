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
// Description: Randomized test sequence

class store_queue_sequence  extends store_queue_if_sequence;

   `uvm_object_utils(store_queue_sequence);

   function new(string name = "store_queue_sequence");
      super.new(name);
   endfunction : new

   task body();
      store_queue_if_seq_item command;

      command = store_queue_if_seq_item::type_id::create("command");
      `uvm_info("Store Queue Sequence", "Starting store_queue sequence", UVM_LOW)

      for(int i = 0; i <= 100; i++) begin
          start_item(command);

          void'(command.randomize());

          finish_item(command);
      end
      `uvm_info("Store Queue Sequence", "Finished store_queue sequence", UVM_LOW)
   endtask : body

endclass : store_queue_sequence
