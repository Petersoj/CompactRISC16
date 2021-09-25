//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: mux16_1
// Description: A generic 16-bit multiplexer (mux) built from a tree of 2-to-1
// multiplexers.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// Generic 2-to-1 multiplexer.
module mux2_1 (input wire [1:0]INPUT, input wire s, output wire OUT);
assign OUT = (~s & INPUT[0]) | (s & INPUT[1]);
endmodule

    // Module for a 4-to-1 multiplexer, to be combined in a tree for the final 16-to-1 mux.
    module mux4_1 (input wire [3:0]INPUT, input wire[1:0]s, output wire OUT);
wire[1:0] layer1;
mux2_1 m1 (INPUT[1:0], s[0], layer1[0]);
mux2_1 m2 (INPUT[3:2], s[0], layer1[1]);
mux2_1 m3 (layer1[1:0], s[1], OUT);
endmodule

    // Final 16-to-1 multiplexer as a tree of 4-to-1 multiplexers.
    module mux16_1 (input wire [15:0]INPUT, input wire[3:0]s, output wire OUT);
wire[3:0] layer2;
mux4_1 m1 (INPUT[3:0], s[1:0], layer2[0]);
mux4_1 m2 (INPUT[7:4], s[1:0], layer2[1]);
mux4_1 m3 (INPUT[11:8], s[1:0], layer2[2]);
mux4_1 m4 (INPUT[15:12], s[1:0], layer2[3]);

mux4_1 m5 (layer2[3:0], s[3:2], OUT);
endmodule
