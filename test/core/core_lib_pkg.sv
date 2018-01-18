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
// Description: Main test package contains all necessary packages

package core_lib_pkg;
    // Standard UVM import & include:
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // Import the core and memory interface agent
    import core_if_agent_pkg::*;
    import dcache_if_agent_pkg::*;
    import mem_if_agent_pkg::*;
    // ------------------------------------------------
    // Environment which will be instantiated
    // ------------------------------------------------
    import core_env_pkg::*;
    // ----------------
    // Sequence Package
    // ----------------
    import core_sequence_pkg::*;
    // Test based includes like base test class and specializations of it
    // ----------------
    // Base test class
    // ----------------
    `include "core_test_base.svh"
    // -------------------
    // Child test classes
    // -------------------
    `include "core_test.svh"

endpackage
