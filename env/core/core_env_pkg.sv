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
// Description: core package

package core_env_pkg;
    // Standard UVM import & include:
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // Testbench related imports
    import core_if_agent_pkg::*;
    import dcache_if_agent_pkg::*;
    import mem_if_agent_pkg::*;
    // ----------------
    // Core test Utils
    // ----------------
    `include "core_test_util.svh"
    // DCache Scoreboard
    `include "dcache_scoreboard.svh"
    // string buffer for console output
    `include "../../common/string_buffer.svh"
    // EOC signaling
    `include "core_eoc.svh"
    // Includes for the config for the environment
    `include "core_env_config.svh"
    // Includes the environment
    `include "core_env.svh"
endpackage
