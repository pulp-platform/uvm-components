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
// Description: core_if Sequencer for core_if_sequence_item

class core_if_sequencer extends uvm_sequencer #(core_if_seq_item);

    // UVM Factory Registration Macro
    `uvm_component_utils(core_if_sequencer)

    // Standard UVM Methods:
    function new(string name="core_if_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass: core_if_sequencer


