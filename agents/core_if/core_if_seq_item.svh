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
// Date: 08.05.2017
// Description: core_if Sequence item

class core_if_seq_item extends uvm_sequence_item;

    // UVM Factory Registration Macro
    `uvm_object_utils(core_if_seq_item)

    //------------------------------------------
    // Data Members (Outputs rand, inputs non-rand)
    //------------------------------------------
    // TODO: set data members

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "core_if_seq_item");
        super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
        core_if_seq_item rhs_;

        if(!$cast(rhs_, rhs)) begin
          `uvm_fatal("do_copy", "cast of rhs object failed")
        end
        super.do_copy(rhs);
        // Copy over data members:
        // e.g.:
        // operator = rhs_.operator;

    endfunction:do_copy

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        core_if_seq_item rhs_;

        if(!$cast(rhs_, rhs)) begin
          `uvm_error("do_copy", "cast of rhs object failed")
          return 0;
        end
        // TODO
        return super.do_compare(rhs, comparer); // && operator == rhs_.operator

    endfunction:do_compare

    function string convert2string();
        string s;

        $sformat(s, "%s\n", super.convert2string());
        // Convert to string function reusing s:
        // TODO
        // $sformat(s, "%s\n operator\n", s, operator);
        return s;

    endfunction:convert2string

    function void do_print(uvm_printer printer);
        if(printer.knobs.sprint == 0) begin
          $display(convert2string());
        end
        else begin
          printer.m_string = convert2string();
        end
    endfunction:do_print

    function void do_record(uvm_recorder recorder);
        super.do_record(recorder);

        // Use the record macros to record the item fields:
        // TODO
        // `uvm_record_field("operator", operator)
    endfunction:do_record

endclass : core_if_seq_item
