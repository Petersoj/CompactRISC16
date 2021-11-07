//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 11/07/2021
// Module Name: cr16_top_tb
// Description: A testbench for the CR16 top module.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

`timescale 1ps/1ps

module cr16_top_tb();

// Inputs
reg clk = 1'b0;

// Outputs
wire [6:0] display [5:0];
wire [4:0] status_flags;

// Establish the clock signal to sync the test
always #5 clk = ~clk;

// Note: if you're running this tb from Modelsim via Quartus Prime, the 'P_BRAM_INIT_FILE'
// directory structure used in the 'cr16_top' module must exist in the 'simulation/modelsim'
// directory, so simply copy the 'resources' folder at the root of this Git project into the
// 'simulation/modelsim' directory.
cr16_top uut
         (.I_CLK(clk),
          .I_NRESET(1'b1),
          .I_MEM_ADDRESS_B(10'b0),
          .O_7_SEGMENT_DISPLAY(display),
          .O_LED_FLAGS(status_flags));

// Use Modelsim's "run for 100ps" feature to advance the simulation of 'cr16_top'

endmodule
