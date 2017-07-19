set config_name       "fibonacci_polyphony"
set config_directory  [file dirname [info script]]
set base_directory    [file join $config_directory ".." ".." ".." "base"]
open_checkpoint [file join $base_directory "base_shell.dcp"   ]
source          [file join $base_directory "base_settings.tcl"]
foreach {pblock} $pblock_list {
    read_checkpoint -cell $pblock_info($pblock.cell) [file join $config_directory ".." "rm" $config_name.dcp]
}
opt_design
place_design
route_design
report_utilization -file [file join $config_directory $config_name.rpt]
report_timing      -file [file join $config_directory $config_name.rpt]  -append
write_checkpoint  -force [file join $config_directory $config_name.dcp]
close_project
