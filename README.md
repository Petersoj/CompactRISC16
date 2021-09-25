# CompactRISC16 (CR16) CPU

This is an implementation of the CompactRISC (CR16) CPU written in Verilog for the Computer Design Laboratory ECE 3710 class at The University of Utah.

## Authors
- Jacob Peterson
- Brady Hartog
- Isabella Gilman
- Nate Hansen

## Verilog Source Naming Conventions and Format
- File names, module names, and wire/reg assignment names should be snake case (e.g. `my_verilog_module.v`)
- Testbench modules and file names should be appended with a `_tb` (e.g. `my_verilog_module_tb.v`)
- Top level modules and file names should be appended with a `_top` (e.g. `my_verilog_module_top.v`)
- There should only be one module per source code file
- Module instantiations should use uppercase named port lists with inputs prepended with `I_` and outputs prepended with `O_` (e.g. `my_verilog_module(.I_INPUT_1(my_input_1), .O_OUTPUT_1(my_output_1));`)
- Module signatures and bodies should use parameters instead of hard-coding constants. When defining the parameters for a module instantiation or for a module signature, the parameter list should start on the next line, but if there is only one parameter, it should be defined on the same line as the module instantiation or signature (same goes for the port list of a module).
- The port list in module signatures should contain `input` and `output` port direction declarations, as opposed to those port direction declarations being placed in the body of the module.
- Module sections should generally follow the following format, from top of file to bottom of file:
  - Module signature with parameter list, then input wires, then output reg/wires
  - `localparam`s that defines constants for the rest of the module
  - Internal register and wire declarations
    - Prepend reg/wire names with `q_` to represent a 'current state' register/wire and `n_` to represent a 'next state' register/wire
  - Output mapping `assign` statements which map internal wires/registers with module output wires/registers
  - RTL logic with `assign` statements for all internal wires which generally consist of ternary operators
  - Module instantiations using named port lists in the instantiation signature and a module instance name that is the same as the module name, but with `i` prepended
  - Clock `@always` blocks which generally should only include `posedge I_CLK` in the sensitivty list
  - Other `@always` (such as internal finite state machines) or `task` blocks

## Verilog Source Formatting
To format verilog source code, use the [`istyle-verilog-formatter`](https://github.com/thomasrussellmurphy/istyle-verilog-formatter) tool via the `format` script:
```
.formatter/verilog/format <paths to files or directories>
```
For example, to recursively format Verilog source files in the `src` directory, use the following command:
```
.formatter/verilog/format src
```
The [`istyle-verilog-formatter`](https://github.com/thomasrussellmurphy/istyle-verilog-formatter) source is provided in the [`.formatter/verilog`](.formatter/verilog) directory along with `format` shell script. The `format` shell script will run `make` if the `iStyle` binary is not already present in the `istyle-verilog-formatter` directory. Note: you may need to make the script executable via: `chmod 755 .formatter/verilog/format`.
