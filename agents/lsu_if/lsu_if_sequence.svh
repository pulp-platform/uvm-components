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
// Description: lsu_if sequence consisting of lsu_if_sequence_items

class lsu_if_sequence extends uvm_sequence #(lsu_if_seq_item);

    // UVM Factory Registration Macro
    `uvm_object_utils(lsu_if_sequence)

    //-----------------------------------------------
    // Data Members (Outputs rand, inputs non-rand)
    //-----------------------------------------------


    //------------------------------------------
    // Constraints
    //------------------------------------------



    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "lsu_if_sequence");
      super.new(name);
    endfunction

    task body;
      lsu_if_seq_item req;

      begin
        req = lsu_if_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        finish_item(req);
      end
    endtask:body

endclass : lsu_if_sequence
