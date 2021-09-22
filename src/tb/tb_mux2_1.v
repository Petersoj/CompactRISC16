`timescale 1ps/1ps

//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: tb_mux16_1
// Description: A generic 2-bit multiplexer (mux). Testbench exhaustively 
// checks correct output.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module tb_mux2_1();

// Inputs
reg [1:0] I_X;
reg s;

// Outputs
wire O_Y;

integer i, j;
// Instantiate the Unit Under Test (UUT)
mux2_1 uut(
				 .INPUT(I_X),
             .s(s),
             .OUT(O_Y)
         );
			
	initial begin
		
		// Wait for global reset.
		#20;
		for( j = 0; j < 2; j = j + 1) begin	
		s = j;
			for( i = 0; i < 4; i = i + 1) begin
				#1;
				I_X = i;
				#2;
				// Check to make sure the output for mux matches bit index.
				if ( O_Y != I_X[j])
					$display("Test Failed: I_X: %b, s: %b, O_Y: %b, i: %b, j:%b", I_X, s, O_Y, i, j);
				
			end
		end
	end
endmodule
