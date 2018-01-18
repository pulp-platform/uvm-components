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
// Description: mem_if Sequence item

class mem_if_seq_item extends uvm_sequence_item;

    // UVM Factory Registration Macro
    `uvm_object_utils(mem_if_seq_item)

    //------------------------------------------
    // Data Members (Outputs rand, inputs non-rand)
    //------------------------------------------
    rand logic [63:0] address;
    rand logic [63:0] data;
    rand logic [7:0]  be;
    rand int requestDelay;
    mode_t mode;
    logic isSlaveAnswer;

    constraint delay_bounds {
        requestDelay inside {[0:10]};
    }
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    function new(string name = "mem_if_seq_item");
      super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
      mem_if_seq_item rhs_;

      if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed")
      end
      super.do_copy(rhs);
      // Copy over data members:
      // e.g.:
      address = rhs_.address;
      data = rhs_.data;
      be = rhs_.be;
      mode = rhs_.mode;
      isSlaveAnswer = rhs_.isSlaveAnswer;
    endfunction:do_copy

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      mem_if_seq_item rhs_;

      if(!$cast(rhs_, rhs)) begin
        `uvm_error("do_copy", "cast of rhs object failed")
        return 0;
      end

      return super.do_compare(rhs, comparer)
        && address == rhs_.address
        && data == rhs_.data
        && be == rhs_.be
        && mode == rhs_.mode;

    endfunction:do_compare

    function string convert2string();
      string s;

      $sformat(s, "%s\n", super.convert2string());
      $sformat(s, "%sMode: %s\nAddress: %0h\nData: %0h\nBE: %0h \nisSlaveAnswer: %h", s, mode.name, address, data, be, isSlaveAnswer);
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
      `uvm_record_field("Mode", mode)
      `uvm_record_field("Address", address)
      `uvm_record_field("Data", data)
      `uvm_record_field("BE", be)
    endfunction:do_record

endclass : mem_if_seq_item
