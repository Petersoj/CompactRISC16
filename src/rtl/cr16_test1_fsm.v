// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: cr16_test1_fsm
// Description: FSM to run as top level module for datapath and ALU portion of 
// the cr16 CPU. 
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_test1_fsm ( input wire I_CLK,
								input wire I_NRESET,
								input wire I_ENABLE,
								output reg [3:0] O_OPCODE,
								output reg [3:0] O_READ_PORT_A_SEL,
								output reg [3:0] O_READ_PORT_B_SEL,
								output reg [15:0] O_REG_ENABLE,
								output reg [15:0] O_PRELOAD_IMM);
								
	// Keep track of next state.
	reg[3:0] NS;
	
	// Parameter aliases for states.
	parameter [3:0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, S5 = 4'b0101,
						 S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001;

	// Next state and sequential logic
	always @ (negedge I_NRESET or posedge I_CLK) begin
	
		if(~I_NRESET)
			NS <= S0;
			
		else 
			case (NS)
				S0: NS <= S1;
				S1: NS <= S2;
				/*S2: NS <= S3;
				S3: NS <= S4;
				S4: NS <= S5;
				S5: NS <= S6;
				S6: NS <= S7;
				S7: NS <= S8;
				S8: NS <= S9;
				S9: NS <= S9;*/
				default: NS <= S0;
			endcase
	end
	
	
	
	// Output logic
	always @ (NS) begin
		case(NS)
			// Load 1 into r0 and set opcode to unsigned addition.
			S0: begin
				O_OPCODE = 4'b0001;
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0000;
				O_REG_ENABLE = 4'h0001
				O_PRELOAD_IMM = 4'h0001;
			end 
			// Load 1 into r1
			S1: begin
				O_OPCODE = 4'b0001;
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0000;
				O_REG_ENABLE = 4'h0002
				O_PRELOAD_IMM = 4'h0001;
			end 
			// Add r0+r1 and store into r2.
			S2: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0001;
				O_REG_ENABLE = 4'h0004
				O_PRELOAD_IMM = 4'h0000;
			end 
			
		endcase
	end
	
endmodule
