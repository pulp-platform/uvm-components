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
// Description: Package containing all ALU sequences

package alu_sequence_pkg;


import fu_if_agent_pkg::*;
import uvm_pkg::*;
import ariane_pkg::*;

`include "uvm_macros.svh"
`include "fibonacci_sequence.svh"
`include "reset_sequence.svh"
`include "basic_sequence.svh"
`include "add_sequence.svh"
`include "addw_sequence.svh"
`include "subw_sequence.svh"
`include "sub_sequence.svh"
`include "xor_sequence.svh"
`include "or_sequence.svh"
`include "and_sequence.svh"
`include "sra_sequence.svh"
`include "srl_sequence.svh"
`include "sll_sequence.svh"
`include "sraw_sequence.svh"
`include "srlw_sequence.svh"
`include "sllw_sequence.svh"

endpackage
