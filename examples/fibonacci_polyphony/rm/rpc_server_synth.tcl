set design_name        fibonacci_polyphony
set project_name       project
set project_directory  [file dirname [info script]]
open_project [file join $project_directory $project_name]
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1
write_checkpoint -force [file join $project_directory $design_name.dcp]
close_design
