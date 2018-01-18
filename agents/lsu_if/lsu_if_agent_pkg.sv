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
// Description: lsu_if_agent package - compile unit

package lsu_if_agent_pkg;
    // UVM Import
    import uvm_pkg::*;
    // import the ariane package for the various data-types
    import ariane_pkg::*;

    `include "uvm_macros.svh"

    // Sequence item to model transactions
    `include "lsu_if_seq_item.svh"
    // Agent configuration object
    `include "lsu_if_agent_config.svh"
    // Driver
    `include "lsu_if_driver.svh"
    // Coverage monitor
    // `include "lsu_if_coverage_monitor.svh"
    // Monitor that includes analysis port
    `include "lsu_if_monitor.svh"
    // Sequencer
    `include "lsu_if_sequencer.svh"
    // Main agent
    `include "lsu_if_agent.svh"
    // Sequence
    `include "lsu_if_sequence.svh"
endpackage: lsu_if_agent_pkg
