################################################################
# Check if script is running in correct Vivado version.
################################################################
array set available_vivado_version_list {"2017.1"   "ok"}
array set available_vivado_version_list {"2017.2"   "ok"}
set available_vivado_version [array names available_vivado_version_list]
set current_vivado_version   [version -short]

if { [string first [lindex [array get available_vivado_version_list $current_vivado_version] 1] "ok"] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$available_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$available_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# CHANGE DESIGN NAME HERE
set design_name rpc_server

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: RPC_SERVER
proc create_hier_cell_RPC_SERVER { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_RPC_SERVER() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 I
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 O

  # Create pins
  create_bd_pin -dir I -type rst ARESETn
  create_bd_pin -dir I -type clk CLK

  # Create instance: Fibonacci_Server_ppy_0, and set properties
  set Fibonacci_Server_ppy_0 [ create_bd_cell -type ip -vlnv ikwzm:msgpack:Fibonacci_Server_ppy:1.0 Fibonacci_Server_ppy_0 ]
  set_property -dict [ list \
CONFIG.I_BYTES {4} \
CONFIG.O_BYTES {4} \
 ] $Fibonacci_Server_ppy_0

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {4} \
CONFIG.HAS_TKEEP {1} \
 ] [get_bd_intf_pins /RPC_SERVER/Fibonacci_Server_ppy_0/O]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins I] [get_bd_intf_pins Fibonacci_Server_ppy_0/I]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins O] [get_bd_intf_pins Fibonacci_Server_ppy_0/O]

  # Create port connections
  connect_bd_net -net ARESETn_1 [get_bd_pins ARESETn] [get_bd_pins Fibonacci_Server_ppy_0/ARESETn]
  connect_bd_net -net CLK_1 [get_bd_pins CLK] [get_bd_pins Fibonacci_Server_ppy_0/CLK]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set I [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 I ]
  set_property -dict [ list \
CONFIG.HAS_TKEEP {1} \
CONFIG.HAS_TLAST {1} \
CONFIG.HAS_TREADY {1} \
CONFIG.HAS_TSTRB {0} \
CONFIG.LAYERED_METADATA {undef} \
CONFIG.TDATA_NUM_BYTES {1} \
CONFIG.TDEST_WIDTH {0} \
CONFIG.TID_WIDTH {0} \
CONFIG.TUSER_WIDTH {0} \
 ] $I
  set O [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 O ]

  # Create ports
  set ARESETn [ create_bd_port -dir I -type rst ARESETn ]
  set CLK [ create_bd_port -dir I -type clk CLK ]

  # Create instance: RPC_SERVER
  create_hier_cell_RPC_SERVER [current_bd_instance .] RPC_SERVER

  # Create interface connections
  connect_bd_intf_net -intf_net I_1 [get_bd_intf_ports I] [get_bd_intf_pins RPC_SERVER/I]
  connect_bd_intf_net -intf_net RPC_SERVER_O [get_bd_intf_ports O] [get_bd_intf_pins RPC_SERVER/O]

  # Create port connections
  connect_bd_net -net ARESETn_1 [get_bd_ports ARESETn] [get_bd_pins RPC_SERVER/ARESETn]
  connect_bd_net -net CLK_1 [get_bd_ports CLK] [get_bd_pins RPC_SERVER/CLK]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

