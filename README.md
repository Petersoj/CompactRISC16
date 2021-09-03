# CompactRISC16 (CR16) CPU

This is an implementation of the CompactRISC (CR16) CPU written in Verilog for the Computer Design Laboratory ECE 3710 class at The University of Utah.

## Authors
- Jacob Peterson
- Brady Hartog
- Isabella Gilman
- Nate Hansen

## Verilog Source Formatting
To format verilog source code, use the [`verilog-format`](https://github.com/ericsonj/verilog-format) tool via the `format` script:
```
.formatter/verilog/format <paths to files or directories>
```
For example, to recursively format Verilog source files in the `src` directory, use the following command:
```
.formatter/verilog/format src
```
The [`verilog-format`](https://github.com/ericsonj/verilog-format) built Jar file is provided in the [`.formatter/verilog`](.formatter/verilog) directory along with `format` shell script. Note: you may need to make the script executable via: `chmod 755 .formatter/verilog/format`.
