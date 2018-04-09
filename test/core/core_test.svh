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
// Date: 08.05.2017
// Description: core main test class

class core_test#(int DATA_WIDTH = 64) extends core_test_base #(DATA_WIDTH);

   typedef  uvm_component_registry #(core_test#(DATA_WIDTH),"core_test") type_id;

   static function type_id get_type();
     return type_id::get();
   endfunction

   virtual function uvm_object_wrapper get_object_type();
     return type_id::get();
   endfunction

   function new(string name = "core_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),$sformatf("DATA_WIDTH = %d",DATA_WIDTH),UVM_LOW)
      phase.drop_objection(this);
   endtask


endclass : core_test
