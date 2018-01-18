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
// Date: 12/20/2016
// Description: This package contains all test related functionality.

package alu_lib_pkg;
    // Standard UVM import & include:
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // Import the memory interface agent
    import fu_if_agent_pkg::*;
    import alu_env_pkg::*;
    import alu_sequence_pkg::*;
    // Test based includes like base test class and specializations of it
    // ----------------
    // Base test class
    // ----------------
    `include "alu_test_base.svh"
    // -------------------
    // Child test classes
    // -------------------
    // plain randomized test
    `include "alu_test.svh"

endpackage
