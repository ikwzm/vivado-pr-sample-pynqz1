
.PHONY: all
all:    shell bit

project: project.xpr

project.xpr : create_project.tcl base_bd.tcl
	vivado -mode batch -log create_project.log -journal create_project.jou -source create_project.tcl

synth: base_synth.dcp

base_synth.dcp : project.xpr base_synth.tcl
	vivado -mode batch -log base_synth.log -journal base_synth.jou -source base_synth.tcl

impl:   base_impl.dcp

base_impl.dcp  : base_synth.dcp base_pblock.tcl base_impl.tcl
	vivado -mode batch -log base_impl.log  -journal base_impl.jou  -source base_impl.tcl

shell:  base_shell.dcp

base_shell.dcp : base_impl.dcp  base_pblock.tcl base_shell.tcl
	vivado -mode batch -log base_shell.log -journal base_shell.jou -source base_shell.tcl

bit:    base.bit

base.bit:        base_impl.dcp  base_pblock.tcl base_bit.tcl
	vivado -mode batch -log base_bit.log   -journal base_bit.jou   -source base_bit.tcl

.PHONY: clean
clean:  clean_project clean_dcp clean_bit clean_log clean_jounal

.PHONY: clean_dcp
clean_dcp:
	-rm -f *.dcp

.PHONY: clean_bit
clean_bit:
	-rm -f *.bit

.PHONY: clean_log
clean_log:
	-rm -f *.log

.PHONY: clean_jounal
clean_jounal:
	-rm -f *.jou

clean_project:
	-rm -f project.xpr
