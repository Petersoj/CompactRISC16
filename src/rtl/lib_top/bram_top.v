//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/28/2021
// Module Name: bram_top
// Description: Tests the following features of using block RAM on the DE1-SoC:
// • Reading the contents of a memory initialization file into block RAM.
// • Editing the memory contents.
// • Verifying writeback.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module bram_top
       (input wire I_CLK,
        input wire I_NRESET,
        output wire [6:0] O_7_SEGMENT_DISPLAY [3:0]);

reg clk;
reg [15:0] i_data_a, i_data_b;
reg [15:0] address_a, address_b;
reg write_enable_a, write_enable_b;

wire [15:0] o_data_a, o_data_b;

bram #(.P_BRAM_INIT_FILE("resources/bram_init/bram_top_init.dat"),
       .P_DATA_WIDTH('d16),
       .P_ADDRESS_WIDTH('d10))
     i_bram
     (I_CLK(clk),
      I_DATA_A(i_data_a),
      I_DATA_B(i_data_b),
      I_ADDRESS_A(address_a),
      I_ADDRESS_B(address_b),
      I_WRITE_ENABLE_A(write_enable_a),
      I_WRITE_ENABLE_B(write_enable_b),
      O_DATA_A(o_data_a),
      O_DATA_B(o_data_b));

// TODO: Continue revising and writing from here!

// Declare the next state.
reg [3:0] NS;

// Parameter aliases for states.
parameter [3:0] S0 = 4'b0000,
          S1 = 4'b0001,
          S2 = 4'b0010,
          S3 = 4'b0011,
          S4 = 4'b0100,
          S5 = 4'b0101,
          S6 = 4'b0110,
          S7 = 4'b0111,
          S8 = 4'b1000;

// Next state and sequential logic.
always @ (negedge I_NRESET or posedge I_CLK) begin
    if (~I_NRESET)
        NS <= S0;
    else
    case (NS)
        S0:
            NS <= S1;
        S1:
            NS <= S2;
        S2:
            NS <= S3;
        S3:
            NS <= S4;
        S4:
            NS <= S5;
        S5:
            NS <= S6;
        S6:
            NS <= S7;
        S7:
            NS <= S8;
        S8:
            NS <= S0;
        default:
            NS <= S0;
    endcase
end

// FSM case statements meant to cycle through a few operations in memory. The
// statements should essentially read a few preloaded 16-bit numbers and then
// perform some operations, rewrite the data, and read again to prove that the
// data was written correctly.

endmodule
