open_checkpoint base_impl.dcp
source base_pblock.tcl
write_bitstream -force base.bit
close_design
