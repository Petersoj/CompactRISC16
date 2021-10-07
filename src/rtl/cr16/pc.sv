//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/7/2021
// Module Name: pc
// Description: Program counter to drive the FSM of the CR16 ALU. 
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module pc #(parameter integer P_ADDRESS_WIDTH = 16)( input wire I_CLK,
           input wire I_ENABLE,			  
           input wire I_NRESET,
			  input wire [P_ADDRESS_WIDTH - 1:0]I_ADDRESS,
			  input wire I_ADDRESS_SELECT,			  
			  output reg [P_ADDRESS_WIDTH - 1:0]O_ADDRESS);
			  
			  
	 always@(posedge I_CLK) begin
	  
	   if (I_ENABLE) begin
			if(!I_NRESET)
				O_ADDRESS = 0;
		  
			else begin
				if (I_ADDRESS_SELECT)
					O_ADDRESS = I_ADDRESS;
			
				else
					O_ADDRESS += 1;
			end
		end	

		else
			O_ADDRESS = O_ADDRESS;
	 end
	 
	 
endmodule

