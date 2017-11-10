class core_test_util extends uvm_object; /* base class*/;

/*-------------------------------------------------------------------------------
-- Interface, port, fields
-------------------------------------------------------------------------------*/

    logic [63:0] rmem [2**21];
    string file;
/*-------------------------------------------------------------------------------
-- UVM Factory register
-------------------------------------------------------------------------------*/
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_object_utils(core_test_util)

/*-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------*/
    // Constructor
    function new(string name = "core_test_util");
        super.new(name);

    endfunction : new

        // parses plusargs from command line to return filename
    function string get_file_name();
        uvm_cmdline_processor uvcl = uvm_cmdline_processor::get_inst();
        string base_dir;
        string file_name;
       // get the file name from a command line plus arg
        void'(uvcl.get_arg_value("+BASEDIR=", base_dir));
        void'(uvcl.get_arg_value("+ASMTEST=", file_name));

        file =  {base_dir, "/", file_name};
        return file;
    endfunction : get_file_name

    function void preload_memories(string file);

        uvm_report_info("Program Loader", $sformatf("Pre-loading memory from file: %s\n", file), UVM_LOW);

        // get the objdump verilog file to load our memorys
        $readmemh({file, ".hex"}, this.rmem);

    endfunction : preload_memories

endclass : core_test_util
