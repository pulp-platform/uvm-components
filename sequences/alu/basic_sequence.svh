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
// Date: 09/04/2017
// Description: Basic sequence, all other ALU sequences extend this abstract class

virtual class basic_sequence extends fu_if_seq;

   `uvm_object_utils(basic_sequence);

   function new(string name = "basic");
      super.new(name);
   endfunction : new

   pure virtual function fu_op get_operator();

   task body();
      fu_if_seq_item command;

      command = fu_if_seq_item::type_id::create("command");
      `uvm_info("ALU Sequence", $sformatf("Starting %s sequence", get_operator().name), UVM_LOW)

      for(int i = 0; i <= 100; i++) begin
          start_item(command);

          void'(command.randomize());
          command.operator = get_operator();

          finish_item(command);
      end
      `uvm_info("ALU Sequence", $sformatf("Finished %s sequence", get_operator().name), UVM_LOW)
   endtask : body
endclass : basic_sequence
