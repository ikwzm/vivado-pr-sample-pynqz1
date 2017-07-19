Vivado Partial Reconfiguration Sample Project for PYNQ-Z1
=========================================================

This project is private and temporary, may be deleted.

# Install

```
shell$ git clone https://github.com/ikwzm/vivado-pr-sample-pynqz1.git
shell$ cd vivado-pr-sample-pynqz1
shell$ git submodule init
shell$ git submodule update
shell$ cd msgpack-vhdl-examples
shell$ git submodule init
shell$ git submodule update
```

# Build

## Base System

### Script File description

* base/
  + Makefile              - Makefile for make
  + create_project.tcl    - Tcl script for create project
  + base_bd.tcl           - block design
  + base_pin.xdc          - pin assign
  + base_settings.tcl     - board_part and pblock settings for base system
  + base_synth.tcl        - Tcl script for synthesis 
  + base_impl.tcl         - Tcl script for implementation 
  + base_shell.tcl        - Tcl script for build base_shell.dcp 
  + base_bit.tcl          - Tcl script for write bitstream

### Generate Base System

```
shell$ cd base
shell$ make
```

### Generated File description

* base/
  + Makefile
  + project.*                     - Vivado project for base
  + base_synth.dcp                - Design Checkpoint synthesis done
  + base_impl.dcp                 - Design Checkpoint implementation done
  + base_shell.dcp                - Design Checkpoint remove reconfig partition and lock routed from base_impl.dcp
  + base.bit                      - Bitstream File for base system
  + base_rpc_server_0_partial.bit - Bitstream File for reconfig partition #0


## Build examples/fibonacci_polyphony

### Script File description

* examples/fibonacci_polyphony/
  + Makefile
  + ip/
    * fibonacci_server_ppy/
  + rm/
    * create_project.tcl
    * rpc_server_bd.tcl
    * rpc_server_synth.tcl
  + cfg/
    * implementation.tcl
    * write_bitstream.tcl

### Generate examples/fibonacci_polyphony

```
shell$ cd examples/fibonacci_polyphony
shell$ make
```

### Generated File description

* examples/fibonacci_polyphony/
  + rm/
    * fibonacci_polyphony.dcp
  + cfg/
    * fibonacci_polyphony.dcp
    * fibonacci_polyphony.bit
    * fibonacci_polyphony_rpc_server_0_partial.bit


