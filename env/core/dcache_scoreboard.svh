// Author: Florian Zaruba, ETH Zurich
// Date: 31.10.2017
// Description: Determines end of computation
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

class dcache_scoreboard extends uvm_scoreboard;

    // UVM Factory Registration Macro
    `uvm_component_utils(dcache_scoreboard)

    core_test_util ctu;
    string sig_dump_name;
    string base_dir;
    longint unsigned begin_signature;
    int f;
    //------------------------------------------
    // Methods
    //------------------------------------------
    // analysis port
    uvm_analysis_imp #(mem_if_seq_item, dcache_scoreboard) store_export;
    uvm_analysis_imp #(dcache_if_seq_item, dcache_scoreboard) load_export;
    uvm_analysis_imp #(dcache_if_seq_item, dcache_scoreboard) ptw_export;

    // get the command line processor for parsing the plus args
    static uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();
    // Standard UVM Methods:
    function new(string name = "dcache_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

         void'(uvcl.get_arg_value("+BASEDIR=", base_dir));

        if (!uvm_config_db #(core_test_util)::get(this, "", "memory_file", ctu))
            `uvm_fatal("DCache Scoreboard", "Cannot get path to pre-load file")

        this.ctu = ctu;

        if (!uvm_config_db #(longint unsigned)::get(this, "", "begin_signature", begin_signature))
            `uvm_fatal("VIF CONFIG", "Cannot get() interface core_if from uvm_config_db. Have you set() it?")

        // check if the argument was supplied
        if(uvcl.get_arg_value("+signature=", this.sig_dump_name) == 0) begin
            sig_dump_name = "test.ariane.sig";
        end

        // create the analysis export
        store_export  = new("store_export", this);
        load_export  = new("load_export", this);
        ptw_export  = new("ptw_export", this);
    endfunction

    function void write (uvm_sequence_item seq_item);
        mem_if_seq_item store_seq_item = new;
        dcache_if_seq_item load_seq_item = new;
        automatic logic [63:0] addr;
        // this was a write
        if (seq_item.get_type_name() == "mem_if_seq_item") begin
            $cast(store_seq_item, seq_item.clone());

            for (int i = 0; i < 8; i++) begin
                if (store_seq_item.be[i]) begin
                    addr = store_seq_item.address[63:0] - 64'h8000_0000;
                    ctu.rmem[addr[63:3]][8*i+:8] = store_seq_item.data[8*i+:8];
                    // $display("%h\n", store_seq_item.data[8*i+:8]);
                end
            end
        // this was a read
        end

        if (seq_item.get_type_name() == "dcache_if_seq_item") begin
            $cast(load_seq_item, seq_item.clone());
            // $display("%s", load_seq_item.convert2string());
            addr = load_seq_item.address[63:0] - 64'h8000_0000;
            if (load_seq_item.data !== ctu.rmem[addr[63:3]]) begin
                `uvm_fatal("DCache Scoreboard", $sformatf("Mismatch: Expected: %h Got: %h @%h", ctu.rmem[addr[63:3]], load_seq_item.data, load_seq_item.address[63:0]));
            end

        end
    endfunction


    task run_phase(uvm_phase phase);

    endtask

    virtual function void extract_phase (uvm_phase phase );
        automatic logic [63:0] addr = begin_signature;
        super.extract_phase(phase);
        `uvm_info("Sig Dump", $sformatf("Dumping Signature File: %s", {base_dir, sig_dump_name}), UVM_HIGH);
        // Dump Signature
        if (this.begin_signature != '0) begin
            this.f = $fopen({base_dir, "/", sig_dump_name}, "w");
            // extract 256 byte register dump + 1024 byte memory dump starting from begin_signature symbol
            for (int i = this.begin_signature; i < this.begin_signature + 162; i += 2)
                $fwrite(this.f, "%x%x\n", this.ctu.rmem[i + 1], this.ctu.rmem[i]);

            $fclose(this.f);
        end
    endfunction

endclass : dcache_scoreboard
