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
// Description: Fibonacci sequence, loosely based on 'The UVM Primer'
//              by Ray Salemi

class fibonacci_sequence extends fu_if_seq;

   `uvm_object_utils(fibonacci_sequence);

   function new(string name = "fibonacci");
      super.new(name);
   endfunction : new


   task body();
      byte unsigned n_minus_2=0;
      byte unsigned n_minus_1=1;
      fu_if_seq_item command;

      command = fu_if_seq_item::type_id::create("command");

      // reset
      start_item(command);
      command.operand_a = 0;
      command.operand_b = 0;
      command.operand_c = 0;
      command.operator = 7'b00;
      finish_item(command);

      `uvm_info("FIBONACCI", " Fib(01) = 00", UVM_MEDIUM);
      `uvm_info("FIBONACCI", " Fib(02) = 01", UVM_MEDIUM);
      for(int ff = 3; ff<=14; ff++) begin
       start_item(command);
       command.operand_a = n_minus_2;
       command.operand_b = n_minus_1;
       command.operator = 7'b00;

       finish_item(command);

       n_minus_2 = n_minus_1;
       n_minus_1 = command.result;

       `uvm_info("FIBONACCI", $sformatf("Fib(%02d) = %02d", ff, n_minus_1),
                 UVM_MEDIUM);
      end
   endtask : body
endclass : fibonacci_sequence
