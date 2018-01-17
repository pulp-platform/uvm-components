// Author: Florian Zaruba, ETH Zurich
// Date: 29.05.2017
// Description: Store Queue scoreboard
//
// Copyright (C) 2017 ETH Zurich, University of Bologna
// All rights reserved.
// This code is under development and not yet released to the public.
// Until it is released, the code is under the copyright of ETH Zurich and
// the University of Bologna, and may contain confidential and/or unpublished
// work. Any reuse/redistribution is strictly forbidden without written
// permission from ETH Zurich.
// Bug fixes and contributions will eventually be released under the
// SolderPad open hardware license in the context of the PULP platform
// (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
// University of Bologna.
class store_queue_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(store_queue_scoreboard);

    uvm_analysis_imp #(store_queue_if_seq_item, store_queue_scoreboard) store_queue_item_export;
    uvm_analysis_imp #(mem_if_seq_item, store_queue_scoreboard) mem_item_export;

    store_queue_if_seq_item store_queue_items [$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        store_queue_item_export = new("store_queue_item_export", this);
        mem_item_export      = new("mem_item_export", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    virtual function void write (uvm_sequence_item seq_item);
        // variables to hold the casts
        store_queue_if_seq_item casted_store_queue = new;
        store_queue_if_seq_item store_queue_item;

        mem_if_seq_item casted_mem = new;


        // got a store queue item
        if (seq_item.get_type_name() == "store_queue_if_seq_item") begin
            // $display("%s", seq_item.convert2string());
            $cast(casted_store_queue, seq_item.clone());
            // this is the first item which is coming, so put it in a queue
            store_queue_items.push_back(casted_store_queue);
        end

        // got an mem item
        if (seq_item.get_type_name() == "mem_if_seq_item") begin
            // cast mem variable
            $cast(casted_mem, seq_item.clone());
            // get the latest store queue item
            store_queue_item = store_queue_items.pop_front();
            // match it with the expected result from the store queue side
            // $display("%s", casted_mem.convert2string());
            if (store_queue_item.address != casted_mem.address ||
                store_queue_item.data != casted_mem.data ||
                store_queue_item.be != casted_mem.be) begin
                `uvm_error("Store Queue Scoreboard", $sformatf("Mismatch. Expected: %s Got: %s", store_queue_item.convert2string(), casted_mem.convert2string()));
            end
        end
    endfunction


endclass : store_queue_scoreboard
