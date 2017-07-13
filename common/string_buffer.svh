// / Author: Florian Zaruba, ETH Zurich
// Date: 13.07.2017
// Description: Buffers a string until a new line appears.
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


class string_buffer extends uvm_component;

    /*-------------------------------------------------------------------------------
    -- Interface, port, fields
    -------------------------------------------------------------------------------*/
    // string buffer
    byte buffer [$];
    // name to display in console
    string logger_name;
    /*-------------------------------------------------------------------------------
    -- UVM Factory register
    -------------------------------------------------------------------------------*/
        // Provide implementations of virtual methods such as get_type_name and create
        `uvm_component_utils(string_buffer)

    /*-------------------------------------------------------------------------------
    -- Functions
    -------------------------------------------------------------------------------*/
        // Constructor
        function new(string name = "string_buffer", uvm_component parent=null);
            super.new(name, parent);
            // default logger name
            logger_name = "String Buffer";
        endfunction : new

        function void set_logger(string logger_name);
            this.logger_name = logger_name;
        endfunction : set_logger

        function void flush();
            string s;
            // dump the buffer out the whole buffer
            foreach (buffer[i]) begin
                s = $sformatf("%s%c",s, buffer[i]);
            end

            uvm_report_info(logger_name, s, UVM_LOW);

            // clear buffer afterwards
            buffer = {};
        endfunction : flush

        // put a char to the buffer
        function void append(byte ch);

            // wait for the new line
            if (ch == 8'hA)
                this.flush();
            else
                buffer.push_back(ch);

        endfunction : append
endclass : string_buffer
