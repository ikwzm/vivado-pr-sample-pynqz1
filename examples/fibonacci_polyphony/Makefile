
ROOT_PATH    = ../
BASE_PATH    = $(ROOT_PATH)/base/
RM_PATH      = ./rm
CFG_PATH     = ./cfg

DESIGN_NAME  = fibonacci_polyphony
SYNTH_NAME   = $(DESIGN_NAME)_synth
IMPL_NAME    = $(DESIGN_NAME)_impl

.PHONY: all
all:    $(CFG_PATH)/$(DESIGN_NAME).bit

project: $(RM_PATH)/project.xpr

$(RM_PATH)/project.xpr : $(RM_PATH)/create_project.tcl $(RM_PATH)/rpc_server_bd.tcl
	vivado -mode batch -log $(RM_PATH)/create_project.log   -journal $(RM_PATH)/create_project.jou   -source $(RM_PATH)/create_project.tcl

$(RM_PATH)/$(DESIGN_NAME).dcp : $(RM_PATH)/project.xpr $(RM_PATH)/rpc_server_synth.tcl
	vivado -mode batch -log $(RM_PATH)/rpc_server_synth.log -journal $(RM_PATH)/rpc_server_synth.jou -source $(RM_PATH)/rpc_server_synth.tcl

$(CFG_PATH)/$(DESIGN_NAME).dcp : $(RM_PATH)/$(DESIGN_NAME).dcp $(CFG_PATH)/implementation.tcl
	vivado -mode batch -log $(CFG_PATH)/implementation.log  -journal $(CFG_PATH)/implementation.jou   -source $(CFG_PATH)/implementation.tcl

$(CFG_PATH)/$(DESIGN_NAME).bit : $(CFG_PATH)/$(DESIGN_NAME).dcp $(CFG_PATH)/write_bitstream.tcl
	vivado -mode batch -log $(CFG_PATH)/write_bitstream.log -journal $(CFG_PATH)/write_bitstream.jou  -source $(CFG_PATH)/write_bitstream.tcl

