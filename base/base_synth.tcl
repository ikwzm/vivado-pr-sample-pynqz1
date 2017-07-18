#
# Open Project
#
set project_directory   "."
set project_name        "project"
open_project [file join $project_directory $project_name]
#
# Run Synthesis
#
launch_runs synth_1
wait_on_run synth_1
#
# Write Design Check Point
#
open_run synth_1 -name synth_1
write_checkpoint -force base_synth.dcp
#
# Close Project
#
close_design

