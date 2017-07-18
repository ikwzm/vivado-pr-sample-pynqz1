open_checkpoint base_synth.dcp

source base_pblock.tcl

foreach {pblock} $pblock_list {
    create_pblock $pblock
    set_property HD.RECONFIGURABLE true       [get_cells -quiet [list $pblock_info($pblock.cell)]]
    add_cells_to_pblock [get_pblocks $pblock] [get_cells -quiet [list $pblock_info($pblock.cell)]]
    resize_pblock       [get_pblocks $pblock] -add $pblock_info($pblock.slice) 
    resize_pblock       [get_pblocks $pblock] -add $pblock_info($pblock.dsp48) 
    resize_pblock       [get_pblocks $pblock] -add $pblock_info($pblock.ramb18)
    resize_pblock       [get_pblocks $pblock] -add $pblock_info($pblock.ramb36)
}

opt_design
place_design
route_design

report_utilization -file "base_impl.rpt"
report_timing      -file "base_impl.rpt"  -append

write_checkpoint -force base_impl.dcp

foreach {pblock} $pblock_list {
    write_checkpoint -force -cell $pblock_info($pblock.cell) $pblock_info($pblock.dcp)
}

close_design


