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
// Date: 09/04/2017
// Description: Sequence specialization, extends basic sequence

class sllw_sequence extends basic_sequence;

   `uvm_object_utils(sllw_sequence);

   function new(string name = "sllw");
      super.new(name);
   endfunction : new

   function fu_op get_operator();
	return SLLW;
   endfunction : get_operator

   task body();
      super.body();
   endtask : body
endclass : sllw_sequence
