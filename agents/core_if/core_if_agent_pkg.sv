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
// Description: core_if_agent package - compile unit

package core_if_agent_pkg;
    // UVM Import
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Sequence item to model transactions
    `include "core_if_seq_item.svh"
    // Agent configuration object
    `include "core_if_agent_config.svh"
    // Driver
    `include "core_if_driver.svh"
    // Coverage monitor
    // `include "core_if_coverage_monitor.svh"
    // Monitor that includes analysis port
    `include "core_if_monitor.svh"
    // Sequencer
    `include "core_if_sequencer.svh"
    // Main agent
    `include "core_if_agent.svh"
    // Sequence
    `include "core_if_sequence.svh"
endpackage: core_if_agent_pkg
