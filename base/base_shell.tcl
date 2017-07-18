open_checkpoint base_impl.dcp

source base_pblock.tcl

foreach {pblock} $pblock_list {
    update_design -cell $pblock_info($pblock.cell) -black_box
}

lock_design -level routing

write_checkpoint -force base_shell.dcp

close_design

