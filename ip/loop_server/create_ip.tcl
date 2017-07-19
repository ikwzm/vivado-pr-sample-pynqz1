#
# create_ip.tcl  Tcl script for create project and generate IP
#
set ip_name                 "loop_server"
set ip_vendor_name          "ikwzm"
set ip_library_name         "pipework"
set ip_root_directory       [file join [file dirname [info script]] $ip_name]
set project_name            "loop_server"
set project_directory       [file join [file dirname [info script]] "work"]
set device_parts            "xc7z010clg400-1"
#
# Create project
#
create_project -force $project_name $project_directory
#
# Set project properties
#
set_property "part"               $device_parts    [get_projects $project_name]
set_property "default_lib"        "xil_defaultlib" [get_projects $project_name]
set_property "simulator_language" "Mixed"          [get_projects $project_name]
set_property "target_language"    "VHDL"           [get_projects $project_name]
#
# Create fileset "sources_1"
#
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
#
# Create fileset "constrs_1"
#
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
#
# Create fileset "sim_1"
#
if {[string equal [get_filesets -quiet sim_1] ""]} {
    create_fileset -simset sim_1
}
#
# Create run "synth_1" and set property
#
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $device_parts -flow "Vivado Synthesis 2014" -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
    set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
    set_property strategy "Flow_PerfOptimized_High"   [get_runs synth_1]
}
current_run -synthesis [get_runs synth_1]
#
# Create run "impl_1" and set property
#
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $device_parts -flow "Vivado Implementation 2014" -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
    set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
    set_property strategy "Performance_Explore"            [get_runs impl_1]
}
current_run -implementation [get_runs impl_1]
#
# Add files
#
proc add_vhdl_file {fileset library_name file_name} {
    set file     [file normalize $file_name]
    set fileset  [get_filesets   $fileset  ] 
    set file_obj [import_files -norecurse -fileset $fileset $file]
    set_property "file_type" "VHDL"        $file_obj
    set_property "library"   $library_name $file_obj
}
proc add_verilog_file {fileset library_name file_name} {
    set file    [file normalize $file_name]
    set fileset [get_filesets   $fileset  ] 
    add_files -norecurse -fileset $fileset $file
    set file_obj [get_files -of_objects $fileset $file]
    set_property "file_type" "Verilog"     $file_obj
    set_property "library"   $library_name $file_obj
}
add_vhdl_file sources_1 WORK src/loop_server.vhd
add_vhdl_file sources_1 WORK src/queue_register.vhd
add_vhdl_file sources_1 WORK src/queue_receiver.vhd
#
# Create IP-Package project
#
ipx::package_project -root_dir $ip_root_directory -vendor $ip_vendor_name -library $ip_library_name -taxonomy /UserIP -generated_files -import_files -force
set_property name         Loop_Server      [ipx::current_core]
set_property display_name Loop_Server_v1_0 [ipx::current_core]
set_property description  Loop_Server_v1_0 [ipx::current_core]
#
# Infer Bus Interfaces
#
ipx::infer_bus_interfaces xilinx.com:interface:aximm_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interfaces xilinx.com:interface:axis_rtl:1.0  [ipx::current_core]
#
# Set Supported Families
#
set_property supported_families {zynq Production virtex7 Production qvirtex7 Production kintex7 Production kintex7l Production qkintex7 Production qkintex7l Production artix7 Production artix7l Production aartix7 Production qartix7 Production zynq Production qzynq Production azynq Production} [ipx::current_core]
#
# Set Core Version
#
set_property core_revision 1 [ipx::current_core]
#
# Generate files
#
ipx::create_xgui_files       [ipx::current_core]
ipx::update_checksums        [ipx::current_core]
ipx::save_core               [ipx::current_core]
#
# Close and Done.
#
close_project
