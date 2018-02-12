add wave -noupdate -group core /core_tb/dut/*

add wave -noupdate -group frontend /core_tb/dut/i_frontend/*
add wave -noupdate -group frontend -group icache /core_tb/dut/i_frontend/i_icache/*
add wave -noupdate -group frontend -group ras /core_tb/dut/i_frontend/i_ras/*
add wave -noupdate -group frontend -group btb /core_tb/dut/i_frontend/i_btb/*
add wave -noupdate -group frontend -group bht /core_tb/dut/i_frontend/i_bht/*
add wave -noupdate -group frontend -group instr_scan /core_tb/dut/i_frontend/i_instr_scan/*

add wave -noupdate -group id_stage -group decoder /core_tb/dut/id_stage_i/decoder_i/*
add wave -noupdate -group id_stage -group compressed_decoder /core_tb/dut/id_stage_i/compressed_decoder_i/*
add wave -noupdate -group id_stage -group instr_realigner /core_tb/dut/id_stage_i/instr_realigner_i/*
add wave -noupdate -group id_stage /core_tb/dut/id_stage_i/*

add wave -noupdate -group issue_stage -group scoreboard /core_tb/dut/issue_stage_i/scoreboard_i/*
add wave -noupdate -group issue_stage -group issue_read_operands /core_tb/dut/issue_stage_i/issue_read_operands_i/*
add wave -noupdate -group issue_stage /core_tb/dut/issue_stage_i/*

add wave -noupdate -group ex_stage -group alu /core_tb/dut/ex_stage_i/alu_i/*
add wave -noupdate -group ex_stage -group mult /core_tb/dut/ex_stage_i/i_mult/*
add wave -noupdate -group ex_stage -group mult -group mul /core_tb/dut/ex_stage_i/i_mult/i_mul/*
add wave -noupdate -group ex_stage -group mult -group div /core_tb/dut/ex_stage_i/i_mult/i_div/*
add wave -noupdate -group ex_stage -group mult -group ff1 /core_tb/dut/ex_stage_i/i_mult/i_ff1/*

add wave -noupdate -group ex_stage -group lsu /core_tb/dut/ex_stage_i/lsu_i/*
add wave -noupdate -group ex_stage -group lsu  -group lsu_bypass /core_tb/dut/ex_stage_i/lsu_i/lsu_bypass_i/*
add wave -noupdate -group ex_stage -group lsu -group mmu /core_tb/dut/ex_stage_i/lsu_i/i_mmu/*
add wave -noupdate -group ex_stage -group lsu -group mmu -group itlb /core_tb/dut/ex_stage_i/lsu_i/i_mmu/itlb_i/*
add wave -noupdate -group ex_stage -group lsu -group mmu -group dtlb /core_tb/dut/ex_stage_i/lsu_i/i_mmu/dtlb_i/*
add wave -noupdate -group ex_stage -group lsu -group mmu -group ptw /core_tb/dut/ex_stage_i/lsu_i/i_mmu/ptw_i/*

add wave -noupdate -group ex_stage -group lsu -group store_unit /core_tb/dut/ex_stage_i/lsu_i/i_store_unit/*
add wave -noupdate -group ex_stage -group lsu -group store_unit -group store_buffer /core_tb/dut/ex_stage_i/lsu_i/i_store_unit/store_buffer_i/*

add wave -noupdate -group ex_stage -group lsu -group load_unit /core_tb/dut/ex_stage_i/lsu_i/i_load_unit/*
add wave -noupdate -group ex_stage -group lsu -group lsu_arbiter /core_tb/dut/ex_stage_i/lsu_i/i_lsu_arbiter/*

add wave -noupdate -group ex_stage -group branch_unit /core_tb/dut/ex_stage_i/branch_unit_i/*

add wave -noupdate -group ex_stage -group csr_buffer /core_tb/dut/ex_stage_i/csr_buffer_i/*
add wave -noupdate -group ex_stage /core_tb/dut/ex_stage_i/*

add wave -noupdate -group commit_stage /core_tb/dut/commit_stage_i/*

add wave -noupdate -group csr_file /core_tb/dut/csr_regfile_i/*

add wave -noupdate -group controller /core_tb/dut/controller_i/*

add wave -noupdate -group debug /core_tb/dut/debug_unit_i/*

add wave -noupdate -group nbdcache /core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/*
add wave -noupdate -group nbdcache -group miss_handler /core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_miss_handler/*

add wave -noupdate -group nbdcache -group bypass_arbiter core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_miss_handler/i_bypass_arbiter/*
add wave -noupdate -group nbdcache -group bypass_axi core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_miss_handler/i_bypass_axi_adapter/*

add wave -noupdate -group nbdcache -group miss_axi core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_miss_handler/i_miss_axi_adapter/*
add wave -noupdate -group nbdcache -group lfsr core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_miss_handler/i_lfsr/*

add wave -noupdate -group nbdcache -group dirty_ram core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/dirty_sram/*
add wave -noupdate -group nbdcache -group tag_cmp core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/i_tag_cmp/*

add wave -noupdate -group nbdcache -group ptw {/core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/master_ports[0]/i_cache_ctrl/*}
add wave -noupdate -group nbdcache -group load {/core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/master_ports[1]/i_cache_ctrl/*}
add wave -noupdate -group nbdcache -group store {/core_tb/dut/ex_stage_i/lsu_i/i_nbdcache/master_ports[2]/i_cache_ctrl/*}

add wave -noupdate -group perf_counters {/core_tb/dut/i_perf_counters/*}

add wave -noupdate -group icache {/core_tb/dut/i_icache/*}
add wave -noupdate -group icache_ctrl {/core_tb/dut/i_icache/i_icache_controller_private/*}
