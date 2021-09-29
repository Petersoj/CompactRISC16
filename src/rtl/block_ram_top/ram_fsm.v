//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/28/2021
// Module Name: bram_fsm
// Description: The FSM meant to control and test reading the contents of a file 
//						to Block RAM, editing the memory contents, and ensuring correct
//						writeback.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module bram_fsm(   input wire I_CLK,
                   input wire I_NRESET,
						 output wire [6:0] O_7_SEGMENT_DISPLAY [3:0])

	// Initialize memory storage for simulation:
	bram I_BRAM(input [(DATA_WIDTH-1):0] data_a, data_b,
					input [(ADDR_WIDTH-1):0] addr_a, addr_b,
					input we_a, we_b, clk,
					output reg [(DATA_WIDTH-1):0] q_a, q_b);
	
	wire 
	
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
