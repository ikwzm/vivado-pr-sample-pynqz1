set config_name        "fibonacci_polyphony"
set config_directory   [file dirname [info script]]
open_checkpoint        [file join $config_directory $config_name.dcp]
write_bitstream -force [file join $config_directory $config_name.bit]
close_design
